#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: Validate CSV submission

requirements:
- class: InlineJavascriptRequirement

inputs:
- id: input_file
  type: File
- id: entity_type
  type: string
- id: subject_id_pattern
  type: string?
- id: min_label
  type: int?
  inputBinding:
    prefix: --min_label
- id: max_label
  type: int?
  inputBinding:
    prefix: --max_label

outputs:
- id: results
  type: File
  outputBinding:
    glob: results.json
- id: status
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['submission_status'])
    loadContents: true
- id: invalid_reasons
  type: string
  outputBinding:
    glob: results.json
    outputEval: $(JSON.parse(self[0].contents)['submission_errors'])
    loadContents: true

baseCommand: validate.py
arguments:
- prefix: -p
  valueFrom: $(inputs.input_file)
- prefix: -e
  valueFrom: $(inputs.entity_type)
- prefix: -o
  valueFrom: results.json
- prefix: --subject_id_pattern
  valueFrom: $(inputs.subject_id_pattern)

hints:
  DockerRequirement:
    dockerPull: docker.synapse.org/syn53708126/pathology-evaluation:v2.0.0 --> needs update we want our docker on synapse

s:author:
- class: s:Person
  s:identifier: https://orcid.org/0000-0002-5622-7998
  s:email: verena.chung@sagebase.org
  s:name: Verena Chung

s:codeRepository:  https://github.com/LISAChallengeOfficial/LISA_infra
s:license: https://spdx.org/licenses/Apache-2.0

$namespaces:
  s: https://schema.org/
