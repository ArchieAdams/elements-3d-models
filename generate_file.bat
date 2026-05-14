for elem in H He Li Be B C N O F Ne Na Mg Al Si P S Cl Ar K Ca; do
    echo "Generating ${elem}..."
    openscad -o "output/${elem}.stl" \
             -D "element=\"${elem}\"" \
             Elements.scad 2>&1 | grep -v "WARNING"
    if [ $? -eq 0 ]; then
        echo "✓ ${elem} complete"
    else
        echo "✗ ${elem} failed"
    fi
done
