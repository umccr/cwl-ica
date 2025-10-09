import {DragenReference} from "../../../schemas/dragen-reference/1.0.0/dragen-reference__1.0.0";
import {
    DragenInputSequenceType,
    StringOrFileType
} from "./dragen-tools_custom_input_interfaces";
import {
    DragenSnvVariantCallerOptions
} from "../../../schemas/dragen-snv-variant-caller-options/4.4.4/dragen-snv-variant-caller-options__4.4.4";
import {FileProperties as IFile} from "cwl-ts-auto";
import {
    DragenCnvCallerOptions
} from "../../../schemas/dragen-cnv-caller-options/4.4.4/dragen-cnv-caller-options__4.4.4";
import {
    DragenMafConversionOptions
} from "../../../schemas/dragen-maf-conversion-options/4.4.4/dragen-maf-conversion-options__4.4.4";
import {DragenSvCallerOptions} from "../../../schemas/dragen-sv-caller-options/4.4.4/dragen-sv-caller-options__4.4.4";
import {
    DragenNirvanaAnnotationOptions
} from "../../../schemas/dragen-nirvana-annotation-options/4.4.4/dragen-nirvana-annotation-options__4.4.4";
import {
    DragenRnaGeneFusionDetectionOptions
} from "../../../schemas/dragen-rna-gene-fusion-detection-options/4.4.4/dragen-rna-gene-fusion-detection-options__4.4.4";
import {
    DragenRnaSpliceVariantCallerOptions
} from "../../../schemas/dragen-rna-splice-variant-caller-options/4.4.4/dragen-rna-splice-variant-caller-options__4.4.4";
import {
    DragenWgtsAlignmentOptions
} from "../../../schemas/dragen-wgts-alignment-options/4.4.4/dragen-wgts-alignment-options__4.4.4";
import {
    DragenTargetedCallerOptions
} from "../../../schemas/dragen-targeted-caller-options/4.4.4/dragen-targeted-caller-options__4.4.4";
import {DragenTmbOptions} from "../../../schemas/dragen-tmb-options/4.4.4/dragen-tmb-options__4.4.4";
import {DragenMsiOptions} from "../../../schemas/dragen-msi-options/4.4.4/dragen-msi-options__4.4.4";
import {DragenMrjdOptions} from "../../../schemas/dragen-mrjd-options/4.4.4/dragen-mrjd-options__4.4.4";

export interface DragenWgtsDnaAlignmentStageOptionsFromPipelineProps {
    sample_name: string
    reference: DragenReference
    ora_reference: IFile
    sequence_data: DragenInputSequenceType,
    alignment_options: DragenWgtsAlignmentOptions,
    lic_instance_id_location: StringOrFileType,
    default_configuration_options: Record<string, any>
}

export interface DragenWgtsRnaAlignmentStageOptionsFromPipelineProps {
    sample_name: string
    reference: DragenReference
    ora_reference: IFile
    sequence_data: DragenInputSequenceType,
    alignment_options: DragenWgtsAlignmentOptions,
    lic_instance_id_location: StringOrFileType,
    default_configuration_options: Record<string, any>
}

export interface DragenWgtsDnaVariantCallingStageOptionsFromPipelineProps {
    sample_name: string
    tumor_sample_name?: string
    reference: DragenReference
    ora_reference: IFile
    sequence_data: DragenInputSequenceType
    tumor_sequence_data?: DragenInputSequenceType
    alignment_options: DragenWgtsAlignmentOptions
    snv_variant_caller_options: DragenSnvVariantCallerOptions
    cnv_caller_options: DragenCnvCallerOptions
    maf_conversion_options: DragenMafConversionOptions
    sv_caller_options: DragenSvCallerOptions
    nirvana_annotation_options: DragenNirvanaAnnotationOptions
    targeted_caller_options: DragenTargetedCallerOptions
    mrjd_options: DragenMrjdOptions
    tmb_options: DragenTmbOptions
    msi_options: DragenMsiOptions
    lic_instance_id_location: StringOrFileType
    default_configuration_options: Record<string, any>
}

export interface DragenWgtsRnaVariantCallingStageOptionsFromPipelineProps {
    sample_name: string
    reference: DragenReference
    ora_reference: IFile,
    sequence_data: DragenInputSequenceType,
    alignment_options: DragenWgtsAlignmentOptions,
    annotation_file: IFile,
    snv_variant_caller_options: DragenSnvVariantCallerOptions,
    gene_fusion_detection_options?: DragenRnaGeneFusionDetectionOptions,
    gene_expression_quantification_options: DragenRnaGeneFusionDetectionOptions,
    splice_variant_caller_options?: DragenRnaSpliceVariantCallerOptions,
    maf_conversion_options?: DragenMafConversionOptions,
    nirvana_annotation_options?: DragenNirvanaAnnotationOptions,
    lic_instance_id_location: StringOrFileType,
    default_configuration_options: Record<string, any>
}

export interface MultiQcNamingOptionsProps {
    sample_name: string
    tumor_sample_name?: string
}