PATH=/net/per610a/export/das11f/plsang/usr/bin:/net/per900a/raid0/plsang/software/gcc-4.8.1/release/bin:/net/per900a/raid0/plsang/software/ffmpeg-2.0/release-shared/bin:/net/per900a/raid0/plsang/usr.local/bin:/net/per900a/raid0/plsang/software/openmpi-1.6.5/release-shared/bin:$PATH
LD_LIBRARY_PATH=/net/per610a/export/das11f/plsang/usr/lib:/net/per900a/raid0/plsang/usr.local/lib64:/net/per900a/raid0/plsang/software/ffmpeg-2.0/release-shared/lib:/net/per900a/raid0/plsang/software/gcc-4.8.1/release/lib:/net/per900a/raid0/plsang/software/boost_1_54_0/release/lib:/net/per900a/raid0/plsang/software/opencv-2.4.6.1/release/lib:/net/per900a/raid0/plsang/usr.local/lib:/net/per900a/raid0/plsang/software/openmpi-1.6.5/release-shared/lib:/usr/local/lib:$LD_LIBRARY_PATH

export PATH
export LD_LIBRARY_PATH

cd ..

python resize_videos.py /net/per610a/export/das11f/plsang/dataset/YouCook/Videos /net/per610a/export/das11f/plsang/youcook/videos_web mp4 yes

