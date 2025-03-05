#back up
cp -r .minecraft .minecraft-backup

#delete
rm -rf .minecraft

mkdir -p .minecraft

#restore saves
cp -r .minecraft-backup/saves .minecraft/saves

cp -r .minecraft-backup/options.txt .minecraft/options.txt
