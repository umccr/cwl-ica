// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {
    Directory_class,
    File_class,
    DirectoryProperties as IDirectory,
    FileProperties as IFile
} from "cwl-ts-auto"

// Backward compatibility with --target es5
declare global {
    interface Set<T> {
    }

    interface Map<K, V> {
    }

    interface WeakSet<T> {
    }

    interface WeakMap<K extends object, V> {
    }
}

// Functions
export function get_file_from_directory(input_dir: IDirectory, file_basename: string, recursive: boolean=false): IFile {
    /*
    Initialise the output file object
    */
    let output_file_obj: IFile | null = null
    /*
    Check input_dir is a directory and has a listing
    */
    if (input_dir.class_ === undefined || input_dir.class_ !== Directory_class.DIRECTORY){
        throw new Error("Could not confirm that the first argument was a directory")
    }
    if (input_dir.listing === undefined || input_dir.listing === null){
        throw new Error(`Could not collect listing from directory "${input_dir.basename}"`)
    }

    /*
    Check that the basename input is defined
    */
    if (file_basename === undefined || file_basename === null){
        throw new Error("Did not receive a name of a file")
    }

    /*
    Collect listing as a variable
    */
    const input_listing: (IDirectory | IFile)[] = input_dir.listing

    /*
    Iterate through the file listing
    */
    for (const listing_item of input_listing) {
        if (listing_item.class_ === File_class.FILE && listing_item.basename === file_basename){
            /*
            Got the file of interest
            */
            output_file_obj = <IFile>listing_item
            break
        }
        if (listing_item.class_ === Directory_class.DIRECTORY && recursive){
            const subdirectory_list = <IDirectory>listing_item
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                output_file_obj = get_file_from_directory(subdirectory_list, file_basename, recursive)
            } catch (error){
                // Dont need to report an error though, just continue
            }
            if (output_file_obj !== null){
                break
            }
        }
    }

    /*
    Ensure we found the file object
    */
    if (output_file_obj === null){
        throw new Error(`Could not find file in the directory ${input_dir.basename}`)
    }

    // Return the output file object
    return output_file_obj
}

// Find files in a directory
export function find_files_in_directory_recursively_with_regex(input_dir: IDirectory, file_regex: RegExp): IFile[] {
    /*
    Initialise the output file object
    */
    const output_file_obj: IFile[] = []
    /*
    Check input_dir is a directory and has a listing
    */
    if (input_dir.class_ === undefined || input_dir.class_ !== Directory_class.DIRECTORY){
        throw new Error("Could not confirm that the first argument was a directory")
    }
    if (input_dir.listing === undefined || input_dir.listing === null){
        throw new Error(`Could not collect listing from directory "${input_dir.basename}"`)
    }

    /*
    Collect listing as a variable
    */
    const input_listing: (IDirectory | IFile)[] = input_dir.listing

    /*
    Iterate through the file listing
    */
    for (const listing_item of input_listing) {
        if (listing_item.class_ === File_class.FILE && file_regex.test(<string>listing_item.basename)){
            /*
            Got the file of interest and the file basename matches the file regex
            */
            output_file_obj.push(<IFile>listing_item)
        }
        if (listing_item.class_ === Directory_class.DIRECTORY){
            const subdirectory_list = <IDirectory>listing_item
            try {
                // Consider that the file might not be in this subdirectory and that is okay
                const subdirectory_files: IFile[] = find_files_in_directory_recursively_with_regex(subdirectory_list, file_regex)
                output_file_obj.push(...subdirectory_files)
            } catch (error){
                // Dont need to report an error though, just continue
            }
        }
    }

    // Return the output file object
    return output_file_obj
}
