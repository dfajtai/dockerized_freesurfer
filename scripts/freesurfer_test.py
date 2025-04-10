"""
    nua9sijp7@mozmail.com
83768
 *C5r5EivIfciQ
 FS/H1Cjiy3C2I
 uCUejYPHdHW6sR0okpOF8BOFvbntQ6j21wYvBF4onqY=

"""

import os
from src.basics.docker_handler import FreeSurfer


# Example usage
fs = FreeSurfer(source_dir=os.path.join(os.getcwd(),"sample_data"),
                license_path=os.path.join(os.getcwd(),"secret","license.txt"))
fs.start()
fs.execute_command("mri_convert /mnt/t.nii /mnt/t.nii.gz")
fs.copy_result("/mnt", "res.tar")
fs.stop()