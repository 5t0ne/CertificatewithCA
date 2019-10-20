usage()
{
	echo "usage: createcert.sh [[p name][-d dns][-c certification authority][-k certification authroity key]]"
}

createconfig()
{
	cat <<Endofmessage > ${name}.ext
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = $dns
Endofmessage
}

name=exampledomain
dns=
ca=
cakey=

if [ $# -le 0 ]; then
	echo "Please specify the required arguments"
else
	while [ "$1" != "" ]; do
		case $1 in
			-p | --privatekey )		                shift
									name=$1
									;;
			-d | --dns 	)			        shift
									dns=$1
									;;
			-c | --ca 	)			        shift
									ca=$1
									;;
			-k | --CAkey 	)		                shift
									cakey=$1
									;;
			* )						usage
									exit 1
		esac
		shift
	done
fi
if [ "$dns" != "" ]; then
	createconfig
else
	echo "Please provide a valid dns name by using the option -d."
fi

#Create private key
openssl genrsa -out "${name}.key" 2048


#Create CSR
openssl req -new -key "${name}.key" -out "${name}.csr"

#Create Certificate
if [ "$ca" != "" ] && [ "$cakey" != "" ]; then
	openssl x509 -req -in "${name}.csr" -CA "$ca" -CAkey "$cakey" -CAcreateserial -out "${name}.crt" -days 1825 -sha256 -extfile "${name}.ext"
else
	echo "Please provide a <myca>.pem via option -c and a <myca>.key via option -k."
fi
