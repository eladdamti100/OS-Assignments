#!/bin/bash 

# First, check if exactly 2 arguments are provided (source PGN file and destination directory)
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <source_pgn_file> <destination_directory>"
    exit 1
fi

# Get the source file and destination directory from the command line
src="$1"
dest="$2"

# Make sure the source file actually exists
if [ ! -f "$src" ]; then
    echo "Error: file '$src' does not exist."
    exit 1
fi

# If the destination directory doesn't exist, create it
if [ ! -d "$dest" ]; then
    mkdir -p "$dest"
    echo "Created directory '$dest'. "
fi

# Define a function to split the PGN file into individual games
split_pgn_file() {
    # Initialize a counter for game files and a buffer to hold game data
    gameIndex=1
    gameBuffer=""
    insideGame=false  # This flag indicate that we starting reading a game

    # Read the source file line by line
    while IFS= read -r currentLine || [[ -n "$currentLine" ]]; do
        currentLine="${currentLine%$'\r'}"
        
        # If the line starts with "[Event ", it's the start of a new game.
        # I use this marker because every PGN game starts with an Event tag.
        if [[ "$currentLine" == "[Event "* ]]; then
            # If we already have game data in the buffer, it means the previous game ended.
            if $insideGame; then
                outputPath="$dest/$(basename "$src" .pgn)_${gameIndex}.pgn"
                echo -e "$gameBuffer" > "$outputPath"
                echo "Saved game to $outputPath"
                gameIndex=$((gameIndex + 1))
                gameBuffer=""  
            fi
            # Mark that we are now inside a game block.
            insideGame=true
        fi
        
        # Add the current line to our game buffer, along with a newline character.
        gameBuffer+="${currentLine}\n"
    done < "$src"

    # After the loop, check if there's any leftover game data and save it.
    if [ -n "$gameBuffer" ]; then
        outputPath="$dest/$(basename "$src" .pgn)_${gameIndex}.pgn"
        echo -e "$gameBuffer" > "$outputPath"
        echo "Saved game to $outputPath"
    fi

    echo "All games have been split and saved to '$dest'."
}

# Call the function to perform the split operation.
split_pgn_file
