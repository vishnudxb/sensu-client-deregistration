# sensu-client-deregistration
A Docker container for deregistering Sensu clients from its master

*You can pull this image from the docker hub*

```
docker pull vishnunair/sensu-client-deregistration

```
*Requirements*

I have 6 ENV variables

```
aws_access_key_id --> Which is your AWS Access Key
aws_secret_access_key --> Which is your AWS Secret Key
region --> Which your AWS Region
sensu_master --> Which is your Sensu Master Server Ipaddress
aws_instance_tag --> Which is your AWS Instance tag
ip_regex --> The ip used by the sensu clients which we used to grep.

```

*What's the purpose of this repo?*

I created this repo for my use case. It may be different for you. 
Let's say I have an ASG group and I used sensu for the monitoring purpose. If the CPU goes up, ASG will create a new instance and I used the user data to add the new instance to the Sensu Server.
And when ASG scales down, it will terminate the instance, so we need to deregister the  terminated instance from the Sensu Server. You can achieve this by several ways. I used a script and add
it to /etc/rc0.d and it executes the script when the instance is terminated. However sometimes it's not executed because of some reasons. So I need to find another way. Some guys use Jenkins to do this.
Instead of Jenkins I created a docker container to do the job.

In sensu, the client name should be unique. So what I did was, I give the ipaddress as the name in the client.json file. I used this 'name' for greping the sensu clients and compare it with the running instances in ASG.

*For eg:- My client.json file for one of the instance in ASG looks like below. For each instance in ASG, it will contain that instance ip as the 'name' and 'address'*

```
{
  "client": {
    "name": "10.0.0.1",
    "address": "10.0.0.1",
    "subscriptions": [
      "production"
    ]
  }
}

```

*You can run the conatiner using the below command*

```
docker run -d --env aws_access_key_id=<accesskey> \
              --env aws_secret_access_key=<secretkey> \
              --env region=<region> \
              --env sensu_master=<sensuserverip> \
              --env aws_instance_tag=<instance-tag> \
              --env ip_regex=<ip_regex> \ 
              vishnunair/sensu-client-deregistration 

```

*For example*
```
docker run -d --env aws_access_key_id=myaccesskeyinhere \ 
              --env aws_secret_access_key=mysecretkeyinhere \ 
              --env region=us-east-1 \ 
              --env sensu_master=10.0.0.1 \ 
              --env aws_instance_tag=production \ 
              --env ip_regex=10 \  
              vishnunair/sensu-client-deregistration 

```
