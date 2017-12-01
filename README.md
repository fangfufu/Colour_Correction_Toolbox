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
  * colour matrices: nx3, this include rgb camera readings, xyz tristimulus triplets, camera sensitivity function, or colour matching function.
  * wave spectrum: nx1, this includes reflectance spectrum, illuminant spectrum.
These are done in order to comply with equation (4a) and (4b) in reference 1.

## Cite this work
Fufu Fang, Han Gong, Michal Mackiewicz, Graham Finlayson. "Colour Correction Toolbox", International Colour Association Congress (AIC), 2017

Please cite the above reference if you have used the code in this toolbox for your work.

## Reference errata in the paper
The reference ```[16]  G. D. Finlayson, H. Gong and R. B. Fisher, “Color homography color correction,” Color and Imaging Conf., pp. 310-314, 2016.``` in the official manuscript should be ```G. D. Finlayson, H. Gong and R. B. Fisher, “Color homography color”, Progress in Colour Studies (PICS), 2016```(i.e. References 3. below). This is because the evaluation for ```Color Homography Color Correction``` carried out in the paper does not contain the RANSAC procedure.

The reference ```B. Funt and P. Bastani, “Simplifying irradiance independent color calibration,” Proc. SPIE, vol. 9015, pp. 90150N``` in the official manuscript should be ```Funt, B., and P. Bastani. "Intensity independent rgb-to-xyz colour camera calibration." AIC (International Colour Association) Conference. Vol. 5. 2012.``` (i.e. References 5. below).

## References of the methods (stably) implemented in this toolbox
1. G. D. Finlayson, M. Mackiewicz and A. Hurlbert, “Root-polynomial colour correction”, IEEE Trans. Image Process., vol. 24, no. 5, pp. 1460-1470, 2015.
2. M. Mackiewicz, C. F. Andersen and G. D. Finlayson, “Method for hue plane preserving color correction”, J. Opt. Soc. Am. A, vol. 33, no. 11, pp. 2166-2177, 2016.
3. G. D. Finlayson, H. Gong and R. B. Fisher, “Color homography”, Progress in Colour Studies (PICS), 2016.
4. G. D. Finlayson and M. S. Drew, “The maximum ignorance assumption with positivity,” Color and Imaging Conf., pp. 202-205, 1996.
5. Funt, B., and P. Bastani. "Intensity independent rgb-to-xyz colour camera calibration." AIC (International Colour Association) Conference. Vol. 5. 2012.


## Future work
* Stable integration of the RANSAC-based color homography color correction (```G. D. Finlayson, H. Gong and R. B. Fisher, “Color homography color correction,” Color and Imaging Conf., pp. 310-314, 2016.```)
* Non-unifrom shading benchmark (as opposed to the current uniform shading tests)

Copyright (c) 2016-2017 Fufu Fang, Han Gong, Graham Finlayson
University of East Anglia, UK.
