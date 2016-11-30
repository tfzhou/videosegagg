## Video Object Segmentation Aggregation (IEEE ICME 2016)

The MATLAB Code for the algorithm described in the paper __Video Object Segmentation Aggregation__, by Tianfei Zhou, Yao Lu, Huijun Di and Jian Zhang appeared at ICME 2016.

The input of our algorithm is a video and the segmentation results given by several algorithms. We aggregate these results in unsupervised ways to obtain more accurate results. In the conference version, we aggregate 5 algorithms and evaluate the performance on SegTrack v1 dataset. Please run _demo.m_ to segment the _girl_ sequence.

Note that in the current version, the computation of optical flow and the object appearance model is expensive. One may consider to improve them in the following ways:

* Use the GPU version of LDOF for optical flow
* Currently, we train the appearance model using foreground and background pixels. When the object is too large or the resolution of the video is too high, it will be very time-consuming. To solve this, one could abstrat each frame into superpixels and then train the model in the superpixel-level.

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
