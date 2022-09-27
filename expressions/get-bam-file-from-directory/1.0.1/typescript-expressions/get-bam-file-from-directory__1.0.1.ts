import {
    Directory_class,
    DirectoryProperties as IDirectory,
    File_class,
    FileProperties as IFile
} from "cwl-ts-auto";

export function get_bam_file_from_directory(input_dir: IDirectory, bam_nameroot: string, recursive: boolean=false): IFile {
    /*
    Initialise the output file object
    */
    let output_bam_obj: IFile | null = null
    let output_bam_index_obj: IFile | null = null

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
    Check that the bam_nameroot input is defined
    */
    if (bam_nameroot === undefined || bam_nameroot === null){
        throw new Error("Did not receive a name of a bam file")
    }

    /*
    Collect listing as a variable
    */
    const input_listing: (IDirectory | IFile)[] = input_dir.listing

    /*
    Iterate through the file listing
    */
    for (const listing_item of input_listing) {
        if (listing_item.class_ === File_class.FILE && listing_item.basename === bam_nameroot + ".bam"){
            /*
            Got the bam file
            */
            output_bam_obj = listing_item
            break
        }
        if (listing_item.class_ === Directory_class.DIRECTORY && recursive){
            try {
                // Consider that the bam file might not be in this subdirectory and that is okay
                output_bam_obj = get_bam_file_from_directory(listing_item, bam_nameroot, recursive)
            } catch (error){
                // Dont need to report an error though, just continue
            }
            if (output_bam_obj !== null){
                break
            }
        }
    }

    /*
    Iterate through the listing again and look for the secondary file
    */
    for (const listing_item of input_listing){
        if (listing_item.class_ === File_class.FILE && listing_item.basename === bam_nameroot + ".bam.bai"){
            /*
            Got the bam index file
            */
            output_bam_index_obj = listing_item
            break
        }
    }

    /*
    Ensure we found the bam object
    */
    if (output_bam_obj === null){
        throw new Error(`Could not find bam file in the directory ${input_dir.basename}`)
    }

    /*
    Check the secondary file has been defined
    */
    if (output_bam_obj.secondaryFiles !== undefined){
        // Picked up index object in the recursion step
    }
    else if (output_bam_index_obj === null) {
        throw new Error(`Could not find secondary file in the directory ${input_dir.basename}`)
    } else {
        /*
        Assign bam index as a secondary file of the output bam object
        */
        output_bam_obj.secondaryFiles = [
            output_bam_index_obj
        ]
    }

    return output_bam_obj
}