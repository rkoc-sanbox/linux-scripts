#!/usr/bin/env python3

import os
import sys

def create_feature(feature_name, base_path):
    structure = [
        f"feature_{feature_name}/data/local",
        f"feature_{feature_name}/data/remote",
        f"feature_{feature_name}/data/repository",
        f"feature_{feature_name}/domain/model",
        f"feature_{feature_name}/domain/repository",
        f"feature_{feature_name}/domain/usecase",
#        f"feature_{feature_name}/presentation/viewmodel",
#        f"feature_{feature_name}/presentation/screen",
    ]
    
    for folder in structure:
        full_path = os.path.join(base_path, folder)
        os.makedirs(full_path, exist_ok=True)
        # create .gitkeep so git tracks empty folders
        open(os.path.join(full_path, ".gitkeep"), "w").close()
        print(f"✅ Created: {folder}")

if __name__ == "__main__":
    feature_name = sys.argv[1]  # e.g. "user_course"
    base_path = sys.argv[2]     # e.g. "./app/src/main/java/com/example"
    create_feature(feature_name, base_path)

