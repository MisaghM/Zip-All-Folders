"""
Zip All Folders

This script zips all the folders in the directory given in the first command-line argument.
(or the current working directory if the arg is left empty)

There is a ZipAllFolders class that does the main job,
and some helper functions. (pause, get_choice, pretty_size)
"""

import os
import sys
import shutil
import zipfile
import getpass
import typing


def pretty_size(size: int, precision: int = 2) -> str:
    """
    Returns human-readable size from bytes.

    Args:
        size: Size in bytes.
        precision: Precision for the result.
    """
    if size >= 1 << 40:
        return f"{size / (1 << 40):.{precision}f} TB"
    if size >= 1 << 30:
        return f"{size / (1 << 30):.{precision}f} GB"
    if size >= 1 << 20:
        return f"{size / (1 << 20):.{precision}f} MB"
    if size >= 1 << 10:
        return f"{size / (1 << 10):.{precision}f} KB"
    return f"{size} B"


class ZipAllFolders:
    """
    Zips all folders in the given directory.

    Attributes:
        location: The directory to zip all folders inside of it.
        rm_folders: Boolean to remove original folders after zipping them.

    Methods:
        zip(): Zips all folders.
        zip_verbose(): Zips all folders and prints the progress.
        zip_generator(): Zips one folder at a time and returns the folder name.
        change_location(location): Changes the location to zip.
    """
    __slots__ = (
        "__location",
        "rm_folders"
    )

    def __init__(self, location: str = ".", rm_folders: bool = False) -> None:
        self.__location = ""
        self.rm_folders = rm_folders
        self.change_location(location)

    def zip(self) -> None:
        folders: list[str] = next(os.walk(self.__location))[1]
        # folders = [f for f in os.listdir(self.__location)
        #            if os.path.isdir(os.path.join(self.__location, f))]

        for folder in folders:
            self.__make_zip(folder)
            if self.rm_folders:
                shutil.rmtree(os.path.join(self.__location, folder))

    def zip_verbose(self) -> None:
        folders: list[str] = next(os.walk(self.__location))[1]

        for i, folder in enumerate(folders):
            print(f"Folder {i + 1}: {folder}")
            self.__make_zip(folder)

            folder_path = os.path.join(self.__location, folder)
            zip_path = folder_path + ".zip"

            print("Size ~", pretty_size(os.path.getsize(zip_path)))

            if self.rm_folders:
                shutil.rmtree(folder_path)
                print("Folder deleted.")

            print()

    def zip_generator(self) -> typing.Iterable[str]:
        folders: list[str] = next(os.walk(self.__location))[1]

        for folder in folders:
            self.__make_zip(folder)
            if self.rm_folders:
                shutil.rmtree(os.path.join(self.__location, folder))
            yield folder

    def __make_zip(self, folder: str) -> None:
        prev_dir = os.getcwd()
        os.chdir(os.path.join(self.__location, folder))

        with zipfile.ZipFile(f"../{folder}.zip", "w", compression=zipfile.ZIP_STORED) as zipf:
            for curr_path, dirs, files in os.walk("."):
                for directory in dirs:
                    zipf.write(os.path.join(curr_path, directory))
                for file in files:
                    zipf.write(os.path.join(curr_path, file))

        os.chdir(prev_dir)

    def change_location(self, location: str) -> None:
        abs_path = os.path.abspath(location)
        if not os.path.isdir(abs_path):
            raise ValueError(f'Location:\n"{abs_path}"\nnot found or is not a folder.')
        self.__location = abs_path


def get_choice(prompt: str) -> bool:
    """Get a yes/no choice from the user."""
    while True:
        choice = input(f"{prompt} [Y,N] ").upper()
        if choice == "Y":
            return True
        if choice == "N":
            return False
        print("Invalid input.")


def pause(message: str) -> None:
    """Wait for enter."""
    print(message, end="", flush=True)
    if sys.stdin.isatty():
        getpass.getpass("")
    else:
        sys.stdin.readline()


def main() -> None:
    location = "."
    if len(sys.argv) > 1:
        location = sys.argv[1]

    rm_folders = get_choice("Remove original folders?")
    print()

    try:
        zipper = ZipAllFolders(location, rm_folders)
        zipper.zip_verbose()
    except ValueError as ex:
        sys.exit(ex)

    print("Done.")
    pause("Press ENTER to continue . . . ")


if __name__ == "__main__":
    main()
