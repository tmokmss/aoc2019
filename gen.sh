# usage: gen.sh [day number]
if [ -z "$1" ];then
    echo "please specify day number"
    exit 1
fi

if [ -f ./$1.rb ]; then
    echo "Error - ${1}.rb already exists"
    exit 1
fi

touch input/$1.txt
touch sample/$1.txt
cp template.rb $1.rb
sed -i "s/DAY/${1}/" $1.rb
