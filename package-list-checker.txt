for pkg in $(cat package-list.txt); do
    if [ -f "$pkg" ]; then
        echo "yes, $pkg is present"
    else
        echo "no, $pkg is missing"
    fi
done