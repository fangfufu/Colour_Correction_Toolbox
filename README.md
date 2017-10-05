# Colour Correction Toolbox

## Folder structure
  * colour_correction_toolbox
    * doc - documentation
    * util - support functions, e.g. data parser / data converters
      * UT_${NAME} for utility functions
      * should include data parsers / file format converters
    * bin - colour correction algorithms - the stuff that the users call
      * CC_${NAME} for colour correction functions
      * EVAL_${NAME} for evaluation function
    * data - sample data file
      * RIT camera database
      * SFU reflectance database
      * SFU illuminant database

## API / Data format
  * colour matrices: $n \times 3$, this include rgb camera readings, xyz tristimulus triplets, camera sensitivity function, or colour matching function.
  * wave spectrum: $n \times 1$, this includes reflectance spectrum, illuminant spectrum.
These are done in order to comply with equation (4a) and (4b) in [1].

## References
1. Finlayson, Graham D., and Mark S. Drew. "The maximum ignorance assumption with positivity." Color and Imaging Conference. Vol. 1996. No. 1. Society for Imaging Science and Technology, 1996.
APA


Copyright (c) 2016-2017 Fufu Fang, Han Gong, Graham Finlayson
University of East Anglia, UK.
