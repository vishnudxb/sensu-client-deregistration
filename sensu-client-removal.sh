#!/bin/bash
sed -i 's/$aws_access_key_id/'"$aws_access_key_id"'/' /root/.aws/credentials
sed -i 's/$aws_secret_access_key/'"$aws_secret_access_key"'/' /root/.aws/credentials
### If your aws secret key contains a '/', then you can use this command sed -i 's#$aws_secret_access_key#'"$aws_secret_access_key"'#' /root/.aws/credentials
sed -i 's/$region/'"$region"'/' /root/.aws/credentials

http http://$sensu_master:4567/clients > /src/clients
jq --raw-output .[].name /src/clients | sed "s/^/name: /" | awk {'print $2'} | grep $ip_regex > /src/api-in-sensu.txt
aws ec2 describe-instances --filter Name=tag:Name,Values=$aws_instance_tag --query 'Reservations[*].Instances[*].[PrivateIpAddress, InstanceId]' --output text | awk {'print $1'} > /src/api-in-aws.txt
diff /src/api-in-sensu.txt /src/api-in-aws.txt > /src/diff.txt
cat /src/diff.txt | grep -e -$ip_regex|sed 's/-//g' > /src/remove-ips.txt

while read ip                    
do                                                      
   curl -X DELETE -L http://$sensu_master:4567/clients/$ip 
done < /src/remove-ips.txt 

