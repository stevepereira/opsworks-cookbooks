#change vpc instance public IP address (EIP -> NIC|INSTANCE)
#usage "changeip [instance friendly tag=Name] [region]"
#example "changeip my.instnace us-west-1"
#dafault region is us-west-1 (you must include --region for $region default)
#for VPC instances only
function changeip {
    if [[ -z $1 ]]; then
        echo 'Error : You must provide tag name for instance'
        echo 'Example:  changeip [friendly name]'
        return
    fi
    if [[ ! -z $2 ]]; then
        region='--region '$2
        echo 'Using region '$2
    else
        region='--region us-east-1' #sets default region
        echo 'Using default '$region
    fi
    name=$1
    instance=$(ec2-describe-instances $region | grep Name | grep $name | cut -f3)
    if [[ ! $instance =~ ^('i-'[A-Za-z0-9]*)$ ]]; then
        echo 'Error : Getting the instance id'
        echo $instance
        return
    fi
    echo 'Applying to '$1 '=> '$instance
    echo 'Please wait....'
    ip_new=$(ec2-allocate-address $region -d vpc | cut -f2)
    if [[ ! $ip_new =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo 'Error : Getting a new IP address'
        echo $ip_new
        return
    fi
    new_idas=$(ec2-describe-addresses $region $ip_new | cut -f 5) >> /dev/null
    if [[ ! $new_idas =~ ^('eipalloc-'[A-Za-z0-9]*)$ ]]; then
        echo 'Error : Getting New IP allocation id eipalloc'
        echo $new_idas
        return  
    fi
    ip_old=$(ec2-describe-addresses $region | grep $instance | cut -f2)
    if [[ ! $ip_old =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        echo 'Error : Getting old IP address'
        echo $ip_old
        return
    fi
    id_dis=$(ec2-describe-addresses $region $ip_old | cut -f 6)
    if [[ ! $id_dis  =~ ^('eipassoc-'[A-Za-z0-9]*)$ ]]; then
        echo 'Error : Dissasociating Old IP'
        echo $id_dis
        return
    fi
    id_release=$(ec2-describe-addresses $region $ip_old | cut -f 5) >> /dev/null
    if [[ ! $new_idas =~ ^('eipalloc-'[A-Za-z0-9]*)$ ]]; then
        echo 'Error : Release Old IP'
        echo $id_release
        return
    fi
    ec2-disassociate-address $region -a $id_dis  >> /dev/null
    sleep 8
    ec2-release-address $region -a $id_release >> /dev/null
    ec2-associate-address $region -i $instance -a $new_idas >> /dev/null
    echo 'SUCCESS!'
    echo 'Old = '$ip_old
    echo 'New = '$ip_new
}
