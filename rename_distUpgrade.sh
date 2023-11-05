for file in *.distUpgrade; do
   echo mv "$file" "${file%.list.distUpgrade}.list"
   mv "$file" "${file%.list.distUpgrade}.list"
done

