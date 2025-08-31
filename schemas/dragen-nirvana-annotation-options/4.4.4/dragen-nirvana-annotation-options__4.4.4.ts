import {FileProperties as IFile} from "cwl-ts-auto"

export interface DragenNirvanaAnnotationOptions {
    /*
    enable variant annotation:

    */
    enable_variant_annotation?: boolean

    /*
    variant annotation assembly:

    */
    variant_annotation_assembly?: IFile

    /*
    variant annotation data:

    */
    variant_annotation_data?: string
}
