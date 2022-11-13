% Batch file for CAT12 segmentation, mean GM ROI extraction to csv,
% TIV & tissue volume extraction for SPM12 standalone installation
%
% ----> CREATE INDIVIDUAL OUTPUT FOLDER BEFORE <----
%
%  input:
%  <*T1w.nii.gz>
%_______________________________________________________________________
% $Id: cat_standalone_batch.txt 1720 23-Sep-2020 22:55:58 fhoffstaedter $
%------------------------------------------------------------------OUTPUTDIR-----

% Used CAT12 version r1720

% INPUT FILE
matlabbatch{1}.spm.tools.cat.estwrite.data(1) = '<UNDEFINED>';

% GM/WM/CSF/WMH
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.native = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.warped = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.GM.dartel = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.native = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.warped = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.mod = 1;
matlabbatch{1}.spm.tools.cat.estwrite.output.WM.dartel = 1;
