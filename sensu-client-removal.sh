#!/bin/bash
http http://$sensu_master:4567/clients > /src/clients
jq --raw-output .[].name /src/clients | sed "s/^/name: /" | awk {'print $2'} | grep 10 > /src/api-in-sensu.txt
aws ec2 describe-instances --filter Name=tag:Name,Values=$aws_instance_tag --query 'Reservations[*].Instances[*].[PrivateIpAddress, InstanceId]' --output text | awk {'print $1'} > /src/api-in-aws.txt
diff /src/api-in-sensu.txt /src/api-in-aws.txt > /src/diff.txt
cat /src/diff.txt | grep -e '-10'|sed 's/-//g' > /src/remove-ips.txt

while read ip                    
do                                                      
   removing ip $ip                                             
   curl -X DELETE -L http://$sensu_master:4567/clients/$ip 
done < /src/remove-ips.txt 

