// Author: Alexis Lucattini
// For assistance on generation of typescript expressions
// In CWL, please visit our wiki page at https://github.com/umccr/cwl-ica/wiki/TypeScript
// Imports
import {
    File as IFile,
    Directory as IDirectory
} from "cwlts/mappings/v1.0"

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
export function get_bam_file_from_directory(directory: IDirectory, filename: string): IFile {
    /*
    Given a listing, return a bam file from in the listing that matches the filename input
     */
    if (directory.listing === null || directory.listing === undefined){
        throw new Error(`Error! Directory '${directory.basename} has no listing attribute`)
    }

    // Local vars
    let bam_file: IFile | null = null
    let bam_file_index: IFile | null = null

    let bam_file_array = directory.listing.filter(
        function (listed_item) {
            return listed_item.basename == filename && listed_item.class == "File"
        }
    )

    let bam_file_index_array = directory.listing.filter(
        function (listed_item) {
            return listed_item.basename == filename + ".bai" && listed_item.class == "File"
        }
    )

    // Check bam file isnt missing
    if (bam_file_array.length == 0){
        throw new Error(`Error! Cannot find bam file '${filename}' in directory '${directory.basename}'`)
    } else {
        bam_file = <IFile> bam_file_array[0]
    }

    // Add index file to bam file if it exists
    if (bam_file_index_array.length == 1){
        // Bam file has an index attach secondary file
        bam_file_index = <IFile> bam_file_index_array[0]
        bam_file.secondaryFiles = [
            bam_file_index
        ]
    }

    return bam_file
}

