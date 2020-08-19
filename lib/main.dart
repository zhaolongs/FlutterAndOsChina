import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// 后来 笔者实现了一个 抖动动画组件 可直接使用上手开发抖动效果
/// https://blog.csdn.net/zl18603543572/article/details/107479836

main() {
  runApp(MaterialApp(
    home: RootPage(),
  ));
}


class RootPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
     return RootPageState();
  }

}

class RootPageState extends State<RootPage> with TickerProviderStateMixin,WidgetsBindingObserver{



  ///正在输入TextField的边框颜色
  Color selectColor = Colors.green;
  ///未在输入TextField的边框颜色
  Color normalColor = Color(0x80fafafa);
  ///手机号焦点控制
  FocusNode userPhoneFieldNode = new FocusNode();
  ///用户密码焦点控制
  FocusNode userPasswordFieldNode = new FocusNode();

  ///用户手机号输入框TextField的控制器
  TextEditingController _userPhoneTextController;
  ///用户密码输入框TextField的控制器
  TextEditingController _userPasswrodtController;


  ///RichText中隐私协议的手势
  TapGestureRecognizer _privacyProtocolRecognizer;
  ///RichText中注册协议的手势
  TapGestureRecognizer _registProtocolRecognizer;


  //注册动画控制器
  AnimationController registerAnimatController;




  //Logo动画控制器
  AnimationController logoAnimatController;
  Animation logoAnimation;


  //输入框动画控制器
  //当输入的手机号不合格或者是密码不合格时
  //通过此动画实现抖动效果
  AnimationController inputAnimatController;
  Animation inputAnimaton;
  ///抖动动画执行次数
  int inputAnimationNumber =0;


  ///输入手机号码合格标识
  /// 11位为合格，此值为false 否则为为true不合格
  bool isPhoneError = false;
  ///输入密码合格标识
  /// 6-12位为合格，此值为false 否则为true不合格
  bool isPasswordError = false;

  ///生命周期函数 页面创建时执行一次
  @override
  void initState() {
    super.initState();

    //输入手机号TextField控制器
    _userPhoneTextController = TextEditingController();
    //输入密码TextField控制器
    _userPasswrodtController = TextEditingController();

    //注册协议的手势
    _registProtocolRecognizer = TapGestureRecognizer();
    //隐私协议的手势
    _privacyProtocolRecognizer = TapGestureRecognizer();

    userPhoneFieldNode.addListener(() {
      setState(() {

      });
    });
    registerAnimatController =
        AnimationController(duration: const Duration(milliseconds: 4000), vsync: this);
    registerAnimatController.addListener(() {
      double value = registerAnimatController.value;
      print("注册变化比率 $value");
      setState(() {
      });
    });

    logoAnimatController = AnimationController(
        duration: const Duration(milliseconds: 400), vsync: this);
    logoAnimatController.addListener(() {
      setState(() {
      });
    });
    logoAnimation = Tween(begin: 1.0, end: 0.0).animate(logoAnimatController);

    //添加监听
    WidgetsBinding.instance.addObserver(this);


    ///这里是通过左右摆动两次来实现的抖动动画
    inputAnimatController = AnimationController(
        duration: const Duration(milliseconds: 100), vsync: this);
    ///构建线性动画，从0-10的匀速
    inputAnimaton =
        new Tween(begin: 0.0, end: 10.0).animate(inputAnimatController);
    ///添加监听，动画执行的每一帧都会回调这里
    inputAnimatController.addListener(() {
      double value = inputAnimatController.value;
      print("变化比率 $value");
      setState(() {
      });
    });
    ///添加动画执行状态监听
    inputAnimatController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        print("正向执行完毕 调用 forward方法动画执行完毕的回调");
        inputAnimationNumber++;
        ///反向执行动画
        inputAnimatController.reverse();
      }else if(status == AnimationStatus.dismissed){
        print("反向执行完毕 调用reverse方法动画执行完毕的回调");
        ///重置动画
        inputAnimatController.reset();
        ///记录动画的执行次数
        ///执行2次便达到了左右抖动的视觉效果
        if(inputAnimationNumber<2){
          //正向执行动画
          inputAnimatController.forward();
        }else{
          inputAnimationNumber=0;
        }
      }
    });

  }
  @override
  void dispose() {
    super.dispose();

    //解绑
    WidgetsBinding.instance.removeObserver(this);
  }

  //应用尺寸改变时回调
  @override
  void didChangeMetrics() {
    super.didChangeMetrics();

    /*
     *Frame是一次绘制过程，称其为一帧，Flutter engine受显示器垂直同步信号"VSync"的驱使不断的触发绘制，
     *Flutter可以实现60fps（Frame Per-Second），就是指一秒钟可以触发60次重绘，FPS值越大，界面就越流畅。
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      //注意，不要在此类回调中再触发新的Frame，这可以会导致循环刷新。
      setState(() {
        ///获取底部遮挡区域的高度
        double keyboderFlexHeight = MediaQuery.of(context).viewInsets.bottom;
        print("键盘的高度 keyboderFlexHeight $keyboderFlexHeight");
        if (MediaQuery.of(context).viewInsets.bottom == 0) {
          //关闭键盘 启动logo动画反向执行 0.0 -1.0
          // logo 布局区域显示出来
          logoAnimatController.reverse();
        } else {
          //显示键盘 启动logo动画正向执行 1.0-0.0
          // logo布局区域缩放隐藏
          logoAnimatController.forward();
        }
      });
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //阻止界面resize
      resizeToAvoidBottomInset : false,
      ///层叠布局
      ///全局的手势
      body: GestureDetector(
        onTap: () {
          //隐藏键盘
          SystemChannels.textInput.invokeMethod('TextInput.hide');
          //输入框失去焦点
          userPhoneFieldNode.unfocus();
          userPasswordFieldNode.unfocus();
        },
        child: Stack(
          children: [
            ///构建背景
            buildBgWidget(),

            ///构建阴影层
            buildBlurBg(),

            ///构建用户信息输入框
            buildLoginInputWidget(),
          ],
        ),
      ),
    );
  }
  ///构建背景
  buildBgWidget() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      bottom: 0,
      child: Image.asset(
        "images/bg_kyzg_login2.png",
        fit: BoxFit.fill,
      ),
    );
  }
  ///构建阴影层
  buildBlurBg() {
    return  Container(
      color: Color.fromARGB(
        155,
        100,
        100,
        100,
      ),
    );
  }
  ///构建用户信息输入框
  buildLoginInputWidget() {
    ///填充
    return Positioned(left: 0, right: 0, top: 0, bottom: 0,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        ///竖直方向的线性布局
        child: Column(
          children: [
            ///顶部距离
            Container(
              margin: EdgeInsets.only(left: 22, right: 22, top: 100.0*logoAnimation.value),
            ),
            ///logo
            buildLogoWidget(),
            //间隔
            SizedBox(height: 30,),
           ///构建用户输入手机号UI
            buildUserRowWidgets(Icons.phone_android,"请输入11位手机号",userPhoneFieldNode,_userPhoneTextController,isPhoneError),
            //间隔
            SizedBox(height: 22,),
            ///构建启用输入密码UI
            buildUserRowWidgets(Icons.lock_open,"请输入6-12密码",userPasswordFieldNode,_userPasswrodtController,isPasswordError),

            buildAgreementWidget(),

            ///间隔
            Container(margin: EdgeInsets.only(top: 40),),
            ///构建注册按钮
            buildRegisterButton(),
          ],
        ),),
    );
  }
  ///构建顶部logo
  buildLogoWidget() {
    ///缩放布局
    return ScaleTransition(
      //设置动画的缩放中心
      alignment: Alignment.center,
      //动画控制器
      scale: logoAnimation,
      //将要执行动画的子view
      child: Row(
        ///主方向子View居中
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            ///圆角矩形
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              child: Image.asset(
                "images/logo.jpg",
                height: 44, width: 44,
              ),
            ),
            padding: EdgeInsets.only(right: 14),
          ),
          Text(
            "Flutter Study",
            style: TextStyle(
              ///文字的大小
                fontSize: 20,
                color: Colors.white,
                ///引用圆滑的自定义字体
                fontFamily: "UniTortred"),
          )
        ],
      ),
    );
  }

  ///构建用户输入手机号、密码通用 UI
  buildUserRowWidgets(IconData preIconData, String hintText,
      FocusNode focusNode, TextEditingController controller,bool isError) {
    return Transform.translate(
      //只有为输入校验错误里才启用左右平移实现抖动提示效果
        offset: Offset(isError?inputAnimaton.value:0, 0),
        child: Container(
          margin: EdgeInsets.only(left: 22, right: 22,),
          decoration: BoxDecoration(
            color: Color(0x50fafafa),
            borderRadius: BorderRadius.all(Radius.circular(30)),
            border: Border.all(
                color: focusNode.hasFocus ? selectColor : normalColor),
          ),
          child: buildInputItemRow(
              preIconData, hintText, focusNode, controller),
        ));
  }

  ///[preIconDate] 输入框前的小图标
  ///[hintText] 提示文字
  ///[focusNode] 焦点控制
  ///[controller]输入框控制器
  buildInputItemRow(IconData preIconDate,String hintText,FocusNode focusNode,TextEditingController controller ) {
    return Row(
      children: [
        ///左侧小图标
        Padding(padding:EdgeInsets.only(left: 10,),child: Icon(preIconDate,color:Color(0xaafafafa),size: 26,),),
        ///竖线
        Padding(
          padding: EdgeInsets.all(10),
          child: Container(width: 1, height: 26, color: Color(0xaafafafa),),
        ),
        ///输入框
       Expanded(child:TextField(
         controller: controller,
         focusNode: focusNode,
         ///点击键盘上的回车按钮回调事件函数
         ///参数[value]获取的是当前TextField中输入的内容
         onSubmitted: (value) {
            print("$value");

            // 电话输入失去焦点
            userPhoneFieldNode.unfocus();
            //密码输入  获取焦点
            FocusScope.of(context).requestFocus(userPasswordFieldNode);

         },
         ///键盘回车键的样式
         textInputAction:TextInputAction.next,
         ///输入文本格式过滤
         inputFormatters: [
           ///输入的内容长度为 11 位
           LengthLimitingTextInputFormatter(11),
         ],
         ///设置键盘的类型
         keyboardType: TextInputType.text,
         ///输入文本的样式
         style: TextStyle(fontSize: 16.0, color: Colors.white),
         decoration: InputDecoration(
           hintText: hintText,
           hintStyle: TextStyle(color: Color(0xaafafafa)),
           border: InputBorder.none,
         ),
       ),),
        ///清除选项
        focusNode.hasFocus
            ? InkWell(
                onTap: () {
                  ///清除输入框内容
                  controller.text="";
                },
                child: Container(
                  margin: EdgeInsets.only(left: 10, right: 12),
                  child: Icon(
                    Icons.cancel,
                    size: 22,
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  ///用户协议
  buildAgreementWidget() {
    return Container(
      margin: EdgeInsets.only(left: 22, right: 22, top: 10),
      child: Row(
        children: [
          ///使用图片切图实现自定义的复选框
          buildCircleCheckBox(),
          SizedBox(width: 1,),
          ///文字区域
          Expanded(
            child: RichText(
              ///文字区域
              text: TextSpan(
                  text: "注册同意",
                  style: TextStyle(color: Color(0xaafafafa)),
                  children: [
                    TextSpan(
                        text: "《用户注册协议》",
                        style: TextStyle(color: Colors.orange),
                        //点击事件
                        recognizer: _registProtocolRecognizer
                          ..onTap = () {
                            print("点击用户协议");
                          }),
                    TextSpan(
                      text: "与",
                      style: TextStyle(color: Color(0xaafafafa)),
                    ),
                    TextSpan(
                        text: "《隐私协议》",
                        style: TextStyle(color: Colors.orange),
                        //点击事件
                        recognizer: _privacyProtocolRecognizer
                          ..onTap = () {
                            print("点击隐私协议");
                          })
                  ]),
            ),
          )
        ],
      ),
    );
  }

  ///复选框的选中标识
  bool checkIsSelect = false;

  ///使用图片素材自定义圆形自选框
  buildCircleCheckBox() {
    return Container(
      padding: EdgeInsets.all(8),
      child: InkWell(
        onTap: () {
          setState(() {
            checkIsSelect = !checkIsSelect;
          });
        },
        child: Image.asset(
          checkIsSelect
              ? "images/no_select_icon.png"
              : "images/select_icon.png",
          width: 18,
          height: 18,
        ),
      ),
    );
  }


  ///注册按钮
  buildRegisterButton() {
    ///点击事件
    return InkWell(
      onTap: () {


        ///隐藏输入框焦点
        userPasswordFieldNode.unfocus();
        userPhoneFieldNode.unfocus();

        ///获取输入的电话号码
        String inputPhone = _userPhoneTextController.text;
        if(inputPhone.length!=11){
          ///更新标识 触发抖动动画
          isPhoneError = true;
          inputAnimatController.forward();
          return;
        }else{
          isPhoneError = false;
        }
        ///获取输入的密码
        String inputPassword = _userPasswrodtController.text;
        if(inputPassword.length<6){
          ///更新标识 触发抖动动画
          isPasswordError = true;
          inputAnimatController.forward();
          return;
        }else{
          isPasswordError = false;
        }


        ///提交数据
        registerAnimatController.forward();

        Future.delayed(Duration(milliseconds: 8000),(){

          ///模拟失败
//          currentRestureStatus = RestureStatus.error;
//          setState(() {
//
//          });
//          Future.delayed(Duration(milliseconds: 2000),(){
//            registerAnimatController.reverse();
//          });

          currentRestureStatus = RestureStatus.success;
          setState(() {
            
          });
          Future.delayed(Duration(milliseconds: 2000),(){
            //跳转首页面
          });
        });
      },
      ///加载进度圆圈与底层显示
      child: Stack(
        children: [
          ///缩放变换
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.diagonal3Values(1.0-registerAnimatController.value,1.0,1.0),
            child :Container(
              alignment: Alignment.center,
              width: MediaQuery.of(context).size.width,
              height: 48,
              margin: EdgeInsets.only(
                left: 22, right: 22,
              ),
              ///圆角矩形背景
              decoration: BoxDecoration(
                  color: Color(0x50fafafa),
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  border: Border.all(color: normalColor)),
              ///透明度
              child: Text(
                "注册",
                style: TextStyle(
                    fontSize: 18,
                    color:Colors.white ,
                    fontWeight: FontWeight.w500),
              ),
            )
          ),
          ///进度圆圈
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ///透明度
              Opacity(
                ///中间显示的Widget透明度
                opacity: registerAnimatController.value,
                child: Container(
                    height: 48.0,
                    width: 48.0,
                    padding: EdgeInsets.all(10),

                    ///根据不同状态来修改不同的注册中间的显示Widget
                    child: buildLoadingWidget(),
                    decoration: BoxDecoration(
                      color: Color(0x50fafafa),
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    )),
              ),
            ],
          ),
        ],
      ),
    );
  }
  RestureStatus  currentRestureStatus = RestureStatus.none;

  ///动态构建不同的显示进度圆圈
  /// 加载中、加载错误、加载成功
  Widget buildLoadingWidget(){

    ///默认使用加载中
    Widget loadingWidget =  CircularProgressIndicator();
    if (currentRestureStatus == RestureStatus.success) {
      ///加载成功显示小对钩
      loadingWidget = Icon(Icons.check,color: Colors.deepOrangeAccent,);
    } else if (currentRestureStatus == RestureStatus.error) {
      ///加载失败状态显示 小X
      loadingWidget = Icon(Icons.close,color: Colors.red,);
    }
    return loadingWidget;

  }

}


enum RestureStatus{
  none,//无状态
  loading,//加载中
  success,//加载成功
  error,//加载失败
  rever,//重试
}