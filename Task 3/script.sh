#!/bin/bash

# Loading file
input_file="prilog.txt"

# Create exit file

# 'IFS= ' so that the line including spaces, tabs etc is read as a whole, not as a field separator
while IFS= read -r line; do # '-r' to read escape chars as text
                            # 'line' is a var in which to store read lines

  # Format check for 'kABCDEFGH.kod'
  # Line matches the RegEx
  #echo "Processing line: $line"
  
  line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')  # remove spaces at the beginning and the end of the line

  if [[ "$line" =~ ^k[0-9a-fA-F]{8}\.kod$ ]]; then  # '=~' RegEx matching
                                                    # '^' beginning of the string
                                                    # '8 chars that can be of value 0-9, a-f or A-F (hex value)'
                                                    # '\.' period is read as plain text, not RegEx keyword
                                                    # '$' end of the string
    #echo "Line $line correct"

    # Create a file from every line read
    touch "$line"

    # Extract G (8th) and E (6th) char value from each line
    G=$(echo "$line" | cut -c8)
    #echo "At position G: $G"
    E=$(echo "$line" | cut -c6)
    #echo "At position E: $E"

    G_int=$((16#$G))
    #echo "$G_int"
    E_int=$((16#$E))
    #echo "$E_int"

    # Check if G is even or odd (if G is a letter, its ASCII value is used for arithmetic operations)
    if (( $G_int % 2 == 0 )); then   # G is even
      dir="${G_int}0/${E_int}0"
    else                         # G is odd
      X=$(($G_int - 1))
    fi

    # Create directory
    mkdir -p "$dir"

    # Move file (current line) to the created dir
    mv "$line" "$dir/"
  else
    # Line doesn't match the RegEx
    echo "Invalid file name: $line"
  fi
done < "$input_file"