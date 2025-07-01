cwlVersion: v1.0
class: CommandLineTool

baseCommand: [unzip]

inputs:
  zipfile:
    type: File
    inputBinding:
      position: 1

outputs:
  unzipped:
    type: Directory
    outputBinding:
      glob: .

requirements:
  InitialWorkDirRequirement:
    listing:
      - entry: $(inputs.zipfile)
