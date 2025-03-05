# get date YYYY-MM-DD from first arg
date=$1
verbose=$2
# check date not exists or is not valid
if [[ ! $date =~ ^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$ ]]; then
  echo "Usage: $0 YYYY-MM-DD"
  exit 1
fi

if [ -z "$verbose" ]; then
  verbose=false
fi

grep -a upgraded /var/log/pacman.log| grep "$date" > /tmp/lastupdates.txt
if [ "$verbose" = true ]; then
  echo "Last updates:"
  cat /tmp/lastupdates.txt
fi
awk '{print $4}' /tmp/lastupdates.txt > /tmp/lines1;awk '{print $5}' /tmp/lastupdates.txt | sed 's/(/-/g' > /tmp/lines2
if [ "$verbose" = true ]; then
  echo "Lines 1:"
  cat /tmp/lines1
  echo "Lines 2:"
  cat /tmp/lines2
fi
paste /tmp/lines1 /tmp/lines2 > /tmp/lines
if [ "$verbose" = true ]; then
  echo "Lines:"
  cat /tmp/lines
fi
tr -d "[:blank:]" < /tmp/lines > /tmp/packages
if [ "$verbose" = true ]; then
  echo "Packages:"
  cat /tmp/packages
fi
cd /var/cache/pacman/pkg/
for i in $(cat /tmp/packages); do sudo pacman --noconfirm -U "$i"*; done
