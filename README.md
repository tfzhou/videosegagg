# Video Object Segmentation Aggregation (IEEE ICME 2016)

The MATLAB Code for the algorithm described in the paper __Video Object Segmentation Aggregation__, by Tianfei Zhou, Yao Lu, Huijun Di and Jian Zhang appeared at ICME 2016. Please run _demo.m_ to segment the _girl_ sequence.

Note that in the current version, the computational of optical flow and object appearance model is expensive. To improve these modules, one may consider to improve the codes in the following ways:

* Optical flow: use the gpu version of ldof
* Object Appearance: currently, we train the appearance model using foreground and background pixels. When the object is too large or the resolution of the video is too high, it is very time-consuming. To solve this, we could abstrat each frame into superpixels and then train the model in superpixel-level.

Please cite

```
@inproceedings{zhou2016video,
    title={Video object segmentation aggregation},
    author={Zhou, Tianfei and Lu, Yao and Di, Huijun and Zhang, Jian},
    booktitle={Multimedia and Expo (ICME), 2016 IEEE International Conference on},
    pages={1--6},
    year={2016},
    organization={IEEE}
}
```

Please contact me (removethisifyouarehuman-tfzhou@bit.edu.cn) or create an issue if you have problems to run the codes. 
