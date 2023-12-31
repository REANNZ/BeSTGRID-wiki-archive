#!/bin/bash

source /etc/profile

#
# Add certificates to check for expiration here.
#
# Modify CERTS_TO_CHECK and CERT_WARN_DAYS to
# suit your site.
#
# CERTS_TO_CHECK is a space-separated string of
# certificates to check. Example:
#
# HOST_CERT="/etc/grid-security/hostcert.pem"
# HTTP_CERT="/etc/grid-security/http/httpcert.pem"
# CERTS_TO_CHECK="${HOST_CERT} ${HTTP_CERT}"
# 
HOST_CERT="/etc/grid-security/hostcert.pem"
CERTS_TO_CHECK="${HOST_CERT}"
CERT_WARN_DAYS=30

SECONDS_PER_DAY=86400
CERT_WARN_SECONDS="$(expr ${CERT_WARN_DAYS} "*" ${SECONDS_PER_DAY})"

DESTINATION="$1"
BAD="Not OK"

# we start with success
STATUS="OK"

MAIL_TOOL="mail"

[ -z "$DESTINATION" ] && DISPOSITION="cat" || DISPOSITION="$MAIL_TOOL -s \"$(hostname -f) Periodic System Check\" $DESTINATION"


# TODO: package is relocatable, this should be fixed by %post
#  OR imported from a config file set by %post
LIBDIR="/usr/local/lib/gridpulse"
CERTDIR="/etc/grid-security/certificates"

seconds() {
	date -d "$1" +%s
}

(
# System information

# all executables in LIBDIR
for i in $LIBDIR/*; do
	[ "$i" = "$LIBDIR/*" ] && break # nothing found

	# extra output is sent to root by cron!
	#[ -x "$i" ] && $i || echo "skipping non executable $i" >&2
	[ -x "$i" ] && $i
done

# all lines in $LIBDIR/system_shorts.pulse
cat $LIBDIR/system_shorts.pulse | while read CMD; do
	OUTPUT="$(eval "$CMD")"
	[ -n "$OUTPUT" ] && echo "Info: $OUTPUT"
done

# Raid information
# TODO: check dmesg for a RAID, fail if no ipssend
for Controller in `ipssend getversion 2>/dev/null |
                   awk '/^ServeRAID Controller Number/ {print $NF}'` ; do
  ipssend getconfig $Controller ld 2>/dev/null |
    awk '/Status of logical drive/ {if($NF!~"OKY")exit 1}' && \
    echo "Info: RAID (Controller $Controller) is: OK"   && continue
    echo "Info: RAID (Controller $Controller) is: Not OK"; STATUS="$BAD"
done


# separate check for wallclock and ntp
WALLCLOCK="$(cat /proc/sys/xen/independent_wallclock)"
if [ -n "$WALLCLOCK" ]; then # maybe not on xen?
	echo "Info: Independent wallclock: $WALLCLOCK"

	NTP="$(dpkg-query -l ntp | tail -1 | awk '{print $2"-"$3}'; echo ${PIPESTATUS[0]})"
	NTP_INSTALLED="$(echo "$NTP" | sed -e "N; s/.*\n//")"


	if [ $WALLCLOCK -eq 1 ]; then
		if [ $NTP_INSTALLED -eq 1 ]; then
			STATUS="$BAD"
			echo "WARNING: Using independent wallclock without ntp installed"
		elif service ntpd status | grep -q stopped; then
			STATUS="$BAD"
			echo "WARNING: Using independent wallclock without ntp running"
		else
			NTP_STATUS="$(ntpdc -nc peers | awk '/^*/ {print substr($1, 2) ", offset: " $(NF-1), "jitter: " $NF, "stratum: " $3}')"
			[ -z "$NTP_STATUS" ] && NTP_STATUS="$(ntpstat | head -1)"
			echo "Info: NTP $NTP_STATUS"
		fi
	fi
fi


# all RPMs listed in $LIBDIR/system_packages.pulse

# copy stdin to fd 9
exec 9<&0
# redirect stdin from file
exec < $LIBDIR/system_packages.pulse

while read PACKAGE; do
	OUTPUT="$(dpkg-query -l $PACKAGE | tail -1 | awk '{print $2"-"$3}'; echo ${PIPESTATUS[0]})"
	RESULT=$(echo "$OUTPUT" | sed -e "N; s/.*\n//")
	echo "Package: $(echo "$OUTPUT" | sed -e "N; s/\n.*//")"
	[ $RESULT -ne 0 ] && STATUS="$BAD"
done

# restore stdin and close file
<&9 9<&-


NOW="$(seconds "$(date -u)")"
CRL_STATUS="OK"

# check for valid CRLs
for CERTIFICATE in $CERTDIR/*.0; do
	if [ "$CERTIFICATE" = "$CERTDIR/*.0" ]; then
		echo "Info: No CA certificates found in $CERTDIR"
		continue
	fi

	HASH="$(echo $CERTIFICATE | sed -e "s|.*/\([^/]*\).0|\1|")"
	
	EXPIRY_DATE="$(openssl x509 -in $CERTIFICATE -enddate -noout 2>/dev/null |
			awk -F= '{print $2}')"

	# not sure when this is true?
	[ -z "EXPIRY_DATE" ] && continue

	echo -n "CA: $HASH, $(openssl x509 -in $CERTIFICATE -subject -noout | sed -e "s/^subject= //"), "

	# expired certificate
	if [ $(seconds "$EXPIRY_DATE") -lt $NOW ]; then
		echo "EXPIRED"
		continue
	fi

	CRL="${CERTIFICATE/\.*}.r0"

	if [ ! -e "$CRL" ]; then
		echo "CRL not found"
		# discussed 21/1/08 - not found is OK
		# current globus versions will correctly refuse when no CRL exists
		#STATUS="$BAD"
		continue;
	fi

	CRL_NEXT_UPDATE="$(openssl crl -in $CRL -nextupdate -noout 2>/dev/null |
			awk -F= '{print $2}')"

	# valid CRL, not sure when the first will be false?
	if [ -n "$CRL_NEXT_UPDATE" -a $(seconds "$CRL_NEXT_UPDATE") -ge $NOW ]; then
		echo "CRL OK"
		continue
	fi

	# if we get here, then there's a problem
	echo "CRL problem.  Next update: $CRL_NEXT_UPDATE"

	# special treatment for APAC Certs
	case $HASH in
		1e12d831|21bf4d92)
			STATUS="$BAD" 
			CRL_STATUS="$BAD"
		;;
	esac
done

# check for soon to expire certificates
if [ ! -z "${CERTS_TO_CHECK}" ]; then
	CERT_STATUS="OK"
	for CERTIFICATE in ${CERTS_TO_CHECK}; do
		# Check that certificate exists
		if [ ! -f "${CERTIFICATE}" ]; then
			echo "Certificate ${CERTIFICATE} not found."
			continue
		fi
		END_DATE="$(openssl x509 -in ${CERTIFICATE} -enddate -noout 2>/dev/null)"
		# Is this a valid certificate file?
		if [ $? != 0 ]; then
			echo "Certificate ${CERTIFICATE} is invalid."
			continue
		fi
		EXPIRY_DATE="$(echo ${END_DATE} | awk -F= '{print $2}')"
		NOW="$(date -u)"
		VALID_FOR="$(expr `seconds "${EXPIRY_DATE}"` - `seconds "${NOW}"`)" 
		# Has the certificate already expired?
		if [ ${VALID_FOR} -le 0 ]; then
			echo "Certificate ${CERTIFICATE} has expired."
			STATUS="${BAD}"
			CERT_STATUS="${BAD}"
			continue
		fi
		# Will the certificate expire within CERT_WARN_DAYS days?
		if [ ${VALID_FOR} -lt ${CERT_WARN_SECONDS} ]; then
			echo "Certificate ${CERTIFICATE} will expire within ${CERT_WARN_DAYS} days."
			STATUS="${BAD}"
			CERT_STATUS="${BAD}"
			continue
		fi
	done
fi

# check services
IGNORE_SERVICES="iptables anacron"
for SERVICE in $(chkconfig --list | awk "! /${IGNORE_SERVICES/ /|}/ && \$5 == \"3:on\" {print \$1}"); do
	case "$(service $SERVICE status 2>/dev/null | head -n1)" in
		*is\ running*) echo "Service: $SERVICE is OK"
			;;
		*is\ stopped*) echo "Service: $SERVICE is not OK"
			STATUS="$BAD"
			;;
	esac
done

echo "Summary: $(uname -n) is $STATUS"

#[ "$DISPOSITION" = "cat" ] || perl -e 'sleep int(180*rand())'
) | eval $DISPOSITION
