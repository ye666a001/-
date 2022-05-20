unit e;

////////////////////////////////////////////////////////////////////////////////
//
//   易语言支持库开发包(EDK) for Delphi, 1.1
// ---------------------------------------------
// (2008/8, 大连大有吴涛易语言软件开发有限公司)
//
////////////////////////////////////////////////////////////////////////////////
//
// 版权声明：
//     本文件版权为易语言作者吴涛所有，仅授权给第三方用作开发易语言支持库，禁止用于其他任何场合。
//
////////////////////////////////////////////////////////////////////////////////


(*******************************************************************************
!!! 注意：支持库是标准的DLL文件，但文件名的后缀必须固定为.FNx，其中x为一类型字母，目前有意义的后缀有：
    1、“.fne”： 带编辑信息、有运行支持代码的支持库；
    2、“.fnl”： 带编辑信息、无运行支持代码的支持库；
    3、“.fnr”： 不带编辑和声明信息、仅有运行支持代码的支持库；
!!! 编译后直接改名*.dll为*.FNx即可。
*******************************************************************************)

interface

uses sysutils, windows;


// 操作系统类别：
const
  __OS_WIN    = $80000000;  //支持Windows操作系统
  __OS_LINUX  = $40000000;  //支持Linux  操作系统
  __OS_UNIX   = $20000000;  //支持Unix   操作系统

  OS_ALL      = (__OS_WIN or __OS_LINUX or __OS_UNIX);  //支持以上所有操作系统

{*
关于跨操作系统编程支持的技术说明：
  1、新版支持库需要说明其具有哪些操作系统版本，及支持库中所有命令、数据类型、
     数据类型方法、数据类型事件、数据类型属性所支持的操作系统（如果不说明，
     默认不支持任何操作系统!）以上这些信息，在该支持库所具有的所有操作系统版
     本中必须一致。
  2、为了和以前的支持库相兼容，所有m_nRqSysMajorVer.m_nRqSysMinorVer版本号
     小于3.6的都默认为支持Windows操作系统，包括内部的所有命令、数据类型、
     数据类型方法、数据类型事件、数据类型属性。
  3、所有组件固定属性和固定事件都支持所有操作系统。
  4、对于纯工具库不进行操作系统支持检查。
*}

type
  EBool = ( EFalse = 0, ETrue = 1, _dummy_EBoolValue = $0FFFFFFF); //do NOT use _dummy_*

type
  PEBool  = ^EBool;
  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

type
  DTBOOL   = SmallInt;  // SDT_BOOL类型的值类型
  PDTBOOL  = ^DTBOOL;
const
  BL_TRUE  = -1; // SDT_BOOL类型的真值
  BL_FALSE =  0; // SDT_BOOL类型的假值

type PDATE = ^TDateTime; //???

type
  DATA_TYPE  = LongWord;    // 数据类型: _SDT_NULL, _SDT_ALL, SDT_BYTE, SDT_SHORT, SDT_INT, SDT_INT64, SDT_FLOAT, SDT_DOUBLE, SDT_BOOL, SDT_DATE_TIME, SDT_TEXT, SDT_BIN, SDT_SUB_PTR 等
  pDATA_TYPE = ^LongWord;   // DATA_TYPE 参见下面的常量定义

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下是由系统定义的基本数据类型，不可更改。(以下常量数值的定义绝对不会有错!)
  _SDT_NULL     = 0;           // 空白数据类型
  _SDT_ALL      = 2147483648;  // 通用型, 仅用于支持库命令定义其参数或返回值的数据类型，当用于定义库命令参数时，_SDT_ALL可以匹配所有数据类型（数组类型必须符合要求）
  //_SDT_NUM 已废弃
  SDT_BYTE      = 2147483905;  // 字节型
  SDT_SHORT     = 2147484161;  // 短整数型
  SDT_INT       = 2147484417;  // 整数型
  SDT_INT64     = 2147484673;  // 长整数型
  SDT_FLOAT     = 2147484929;  // 小数型
  SDT_DOUBLE    = 2147485185;  // 双精度小数型
  SDT_BOOL      = 2147483650;  // 逻辑型
  SDT_DATE_TIME = 2147483651;  // 日期时间型
  SDT_TEXT      = 2147483652;  // 文本型
  SDT_BIN       = 2147483653;  // 字节集
  SDT_SUB_PTR   = 2147483654;  // 子程序指针
  //_SDT_VAR_REF 已废弃
  SDT_STATMENT  = 2147483656;  // 子语句型，仅用于库命令定义其参数的数据类型。其数据长度为两个INT，第一个记录存根子程序地址，第二个记录该子语句所在子程序的变量栈首。
  // !!! 注意在SDT_STATMENT用作库命令参数时，编译器允许其可以接收所有基本数据类型，所以必须首先判断处理
  (*
  调用例子：
        if (pArgInf->m_dtDataType == SDT_BOOL)
            return pArgInf->m_bool;

        if (pArgInf->m_dtDataType == SDT_STATMENT)
        {
            DWORD dwEBP = pArgInf->m_statment.m_dwSubEBP;
            DWORD dwSubAdr = pArgInf->m_statment.m_dwStatmentSubCodeAdr;
            DWORD dwECX, dwEAX;

            _asm
            {
                mov eax, dwEBP
                call dwSubAdr
                mov dwECX, ecx
                mov dwEAX, eax
            }

            if (dwECX == SDT_BOOL)
                return dwEAX != 0;

            // 释放文本或字节集数据所分配的内存。
            if (dwECX == SDT_TEXT || dwECX == SDT_BIN)
                MFree (( void* )dwEAX);
        }

        GReportError ("用作进行条件判断的子语句参数只能接受逻辑型数据");
  *)


const
  // 用作区分系统类型、用户自定义类型、库定义数据类型
  DTM_SYS_DATA_TYPE_MASK  = $80000000;
  DTM_USER_DATA_TYPE_MASK = $40000000;
  DTM_LIB_DATA_TYPE_MASK  = $00000000;

  // 用作细分用户自定义数据类型
  UDTM_USER_DECLARE_MASK  = $00000000;  // 用户自定义复合数据类型
  UDTM_WIN_DECLARE_MASK   = $10000000;  // 用户自定义窗口类型

  // 在数据类型中的数组标志，如果某数据类型值此位置1，则表示为此数据类型的数组。
  // 本标志仅用作在运行时为具有AS_RECEIVE_VAR_OR_ARRAY或AS_RECEIVE_ALL_TYPE_DATA
  // 标志的库命令参数说明其为是否为数组数据，其他场合均未使用。因此其他地方均
  // 可以忽略本标志。
  DT_IS_ARY  = $20000000;

  // 在数据类型中的传址标志，如果某数据类型值此位置1，则表示为此数据类型的变量地址。
  // 本标志仅用作在运行时为具有AS_RECEIVE_VAR_OR_OTHER标志的库命令参数说明其为是否为
  // 变量地址，其他场合均未使用。因此其他地方均可以忽略本标志。
  // 本标志与上标志不能共存。
  DT_IS_VAR  = $20000000;

  // 程序的版本类型宏
  PT_EDIT_VER         = 1; // 为用作编辑的版本
  PT_DEBUG_RUN_VER    = 2; // 为DEBUG调试运行版本
  PT_RELEASE_RUN_VER  = 3; // 为RELEASE最终运行版本

  
type
  //////////////////////////////////////////////////////////////////////////////
  // “参数信息”数据结构 ARG_INFO

  pARG_INFO = ^ARG_INFO;
  ARG_INFO  = record
    m_szName         : PChar;     // 参数名称
    m_szExplain      : PChar;     // 参数详细解释
    m_shtBitmapIndex : SmallInt;  // 参见 CMD_INFO 中的同名成员
    m_shtBitmapCount : SmallInt;  // 参见 CMD_INFO 中的同名成员
    m_dtDataType     : DATA_TYPE; // 参数的数据类型
    m_nDefault       : LongWord;  // 参数默认值，见下面的说明
    m_dwState        : LongWord;  // 状态值，见下面的说明和常量定义

    ////////////////////////////////////////////////////////////////////////////
    //
    // 其中, m_nDefault 为系统基本类型参数的默认指定值（在编译时编译器将自动处理）：
    //
    //   1、数值型：直接为数值（如为小数，只能指定其整数部分，如为长整数，只能指定不超过INT限值的部分）；
    //   2、逻辑型：1 代表'真'，0 代表'假'；
    //   3、文本型：本成员此时为PChar指针，指向默认文本串；
    //   4、其它所有类型参数一律无默认指定值。
    //
    // 其中, m_dwState 可以为 0 和以下数值的组合：（0 表示该参数没有默认值，用户必须提供该参数）
    //
    //   AS_HAS_DEFAULT_VALUE      = (1 shl 0);  // 本参数有默认值，默认值在m_nDefault中说明。本参数在编辑程序时已被处理，编译时不需再处理。
    //   AS_DEFAULT_VALUE_IS_EMPTY = (1 shl 1);  // 本参数有默认值，默认值为空，与上标志互斥。运行时所传递过来的参数数据类型可能为_SDT_NULL(表示没有参数传入)。
    //   AS_RECEIVE_VAR            = (1 shl 2);  // 为本参数提供数据时只能提供单一变量，而不能提供整个变量数组、立即数或命令返回值。运行时所传递过来的参数数据肯定是内容不为数组的变量地址。
    //   AS_RECEIVE_VAR_ARRAY      = (1 shl 3);  // 为本参数提供数据时只能提供整个变量数组，而不能提供单一变量、立即数或命令返回值。
    //   AS_RECEIVE_VAR_OR_ARRAY   = (1 shl 4);  // 为本参数提供数据时只能提供单一变量或整个变量数组，而不能提供立即数或命令返回值。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_ARY来标志其是否为数组。
    //   AS_RECEIVE_ARRAY_DATA     = (1 shl 5);  // 为本参数提供数据时只能提供数组数据，如不指定本标志，默认为只能提供非数组数据。如指定了本标志，运行时所传递过来的参数数据肯定为数组。
    //   AS_RECEIVE_ALL_TYPE_DATA  = (1 shl 6);  // 为本参数提供数据时可以同时提供非数组或数组数据，与上标志互斥。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_ARY来标志其是否为数组。
    //   AS_RECEIVE_VAR_OR_OTHER   = (1 shl 9);  // 为本参数提供数据时可以提供单一变量或立即数或命令返回值，不能提供数组。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_VAR来标志其是否为变量地址。
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于 ARG_INFO 结构中的 m_dwState 成员

  AS_HAS_DEFAULT_VALUE      = (1 shl 0);  // 本参数有默认值，默认值在m_nDefault中说明。本参数在编辑程序时已被处理，编译时不需再处理。
  AS_DEFAULT_VALUE_IS_EMPTY = (1 shl 1);  // 本参数有默认值，默认值为空，与上标志互斥。运行时所传递过来的参数数据类型可能为_SDT_NULL(表示没有参数传入)。
  AS_RECEIVE_VAR            = (1 shl 2);  // 为本参数提供数据时只能提供单一变量，而不能提供整个变量数组、立即数或命令返回值。运行时所传递过来的参数数据肯定是内容不为数组的变量地址。
  AS_RECEIVE_VAR_ARRAY      = (1 shl 3);  // 为本参数提供数据时只能提供整个变量数组，而不能提供单一变量、立即数或命令返回值。
  AS_RECEIVE_VAR_OR_ARRAY   = (1 shl 4);  // 为本参数提供数据时只能提供单一变量或整个变量数组，而不能提供立即数或命令返回值。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_ARY来标志其是否为数组。
  AS_RECEIVE_ARRAY_DATA     = (1 shl 5);  // 为本参数提供数据时只能提供数组数据，如不指定本标志，默认为只能提供非数组数据。如指定了本标志，运行时所传递过来的参数数据肯定为数组。
  AS_RECEIVE_ALL_TYPE_DATA  = (1 shl 6);  // 为本参数提供数据时可以同时提供非数组或数组数据，与上标志互斥。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_ARY来标志其是否为数组。
  AS_RECEIVE_VAR_OR_OTHER   = (1 shl 9);  // 为本参数提供数据时可以提供单一变量或立即数或命令返回值，不能提供数组。如果具有此标志，则传递给库命令参数的数据类型将会通过DT_IS_VAR来标志其是否为变量地址。

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // “命令信息”数据结构 CMD_INFO

  pCMD_INFO = ^CMD_INFO;
  CMD_INFO  = record
    m_szName         : PChar;     // 命令中文名称
    m_szEGName       : PChar;     // 命令英文名称，可以为空或nil
    m_szExplain      : PChar;     // 命令详细解释
    m_shtCategory    : SmallInt;  // 全局命令的所属类别，从1开始，减一后的值为指向LIB_INFO的m_szzCategory成员所提供的某个类别字符串的索引; 对象成员命令的此值为-1
    m_wState         : Word;      // 命令状态，见后面的说明，及常量和函数定义
    m_dtRetType      : DATA_TYPE; // 返回值类型，使用前注意转换HIWORD为0的内部数据类型值到程序中使用的数据类型值。
    m_wReserved      : Word;      // 保留，必须为0
    m_shtUserLevel   : SmallInt;  // 难度等级，取值1,2,3，分别代表“初-中-高”级；见后面的说明及常量定义
    m_shtBitmapIndex : SmallInt;  // 指定图像索引，从1开始，0表示无。减一后的值为指向支持库中名为"LIB_BITMAP"的BITMAP资源中某一部分16X13位图的索引
    m_shtBitmapCount : SmallInt;  // 图像数目(用作为IDE提供动画图片)
    m_nArgCount      : LongWord;  // 命令的参数数目
    m_pBeginArgInfo  : pARG_INFO; // 指向本命令的参数定义信息数组

    ////////////////////////////////////////////////////////////////////////////
    // 其中, m_wState 取 0 或以下值的组合：（0 表示该命令为正常命令）
    //   CT_IS_HIDED                = (1 shl 2);  // 本命令是否为隐含命令（即不需要由用户直接输入的命令(如循环结束命令)或被废弃但为了保持兼容性又要存在的命令）
    //   CT_IS_ERROR                = (1 shl 3);  // 本命令在本库中不能使用，具有此标志一定隐含，主要用作在不同语言版本的相同库中使用，即：A命令在A语言版本库中可能需要实现并使用，但在B语言版本库中可能就不需要。如果程序中使用了具有此标志的命令，则只能支持该程序调入和编译，而不能支持运行。如具有此标志，可以不实现本命令的执行部分。
    //   CT_DISABLED_IN_RELEASE_VER = (1 shl 4);  // 具有本标志的命令在易语言系统编译RELEASE版易程序时将被跳过，本类型命令必须无返回值
    //   CT_ALLOW_APPEND_NEW_ARG    = (1 shl 5);  // 在本命令的参数表的末尾是否可以添加新的参数，新参数等同于参数表中的最后一个参数
    //   CT_RETURN_ARRAY_DATA       = (1 shl 6);  // 用于说明m_dtRetType，是否返回数组数据
    //   CT_IS_OBJ_COPY_CMD         = (1 shl 7);
    //   // 说明本命令为某数据类型的复制函数(执行将另一同类型数据类型数据复制到本对象时所需要的
    //   // 额外操作，在编译此数据类型对象的赋值语句时编译器先释放该对象的原有内容，然后生成调用此
    //   // 命令的代码，而不会再生成其它任何常规赋值及复制代码)。
    //   // !!! 1、此命令必须仅接受一个同数据类型参数而且不返回任何数据。
    //   //     2、执行本命令时对象的内容数据为未初始化状态，命令内必须负责初始化其全部成员数据。
    //   //     3、所提供过来的待复制数据类型参数数据可能为全零状态（由编译器自动生成的对象初始代码设置），
    //   // 复制时需要对此情况进行区别处理。
    //   CT_IS_OBJ_FREE_CMD         = (1 shl 8);
    //   // 说明本命令为某数据类型的析构函数(执行当该数据类型数据销毁时所需要的全部操作，
    //   // 当对象超出其作用区域时编译器仅仅生成调用此命令的代码，而不会生成任何常规销毁代码)。
    //   // !!! 1、此命令必须没有任何参数而且不返回任何数据。
    //   //     2、此命令被执行时对象的内容数据可能为全零状态（由编译器自动生成的对象初始代码设置），
    //   // 释放时需要对此情况进行区别处理。
    //   CT_IS_OBJ_CONSTURCT_CMD    = (1 shl 9);
    //   // 说明本命令为某数据类型的构造函数(执行当该数据类型数据初始化时所需要的全部操作，
    //   // !!! 1、此命令必须没有任何参数而且不返回任何数据。
    //   //     2、此命令被执行时对象的内容数据为全零状态。
    //   //     3、指定类型成员（复合数据类型成员、数组成员），必须按照对应格式继续进行下一步初始化。
    //   _CMD_OS(os) // 说明该命令所支持的操作系统。注：_CMD_OS()是一个函数，用作测试指定命令是否支持指定操作系统。
    //
    // 其中, m_shtUserLevel 取以下值之一：
    //   LVL_SIMPLE    = 1;               // 初级
    //   LVL_SECONDARY = 2;               // 中级
    //   LVL_HIGH      = 3;               // 高级
    //
    // !!!!! 千万注意：如果返回值类型(m_dtRetType)定义为 _SDT_ALL ，
    // 绝对不能返回数组(即CT_RETURN_ARRAY_DATA置位)或复合数据类型的数据(即用户或库自定义数据类型但不包含窗口或菜单单元)，因为无法自动删除复合类型中所分配的额外空间(如文本型或者字节集型成员等)。
    // 由于通用型数据只可能通过库命令返回，因此所有_SDT_ALL类型的数据只可能为非数组的系统数据类型或窗口组件、菜单数据类型。
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _CMD_OS(os: LongWord): Word;          // 用作转换os类型以便加入到CMD_INFO.m_wState
  function _TEST_CMD_OS(m_wState: Word; os: LongWord): boolean; // 用作测试指定命令是否支持指定操作系统

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于 CMD_INFO 结构的 m_wState 和 m_shtUserLevel 成员中：

  // 命令状态(m_wState)
  CT_IS_HIDED                = (1 shl 2);  // 本命令是否为隐含命令（即不需要由用户直接输入的命令(如循环结束命令)或被废弃但为了保持兼容性又要存在的命令）
  CT_IS_ERROR                = (1 shl 3);  // 本命令在本库中不能使用，具有此标志一定隐含，主要用作在不同语言版本的相同库中使用，即：A命令在A语言版本库中可能需要实现并使用，但在B语言版本库中可能就不需要。如果程序中使用了具有此标志的命令，则只能支持该程序调入和编译，而不能支持运行。如具有此标志，可以不实现本命令的执行部分。
  CT_DISABLED_IN_RELEASE_VER = (1 shl 4);  // 具有本标志的命令在易语言系统编译RELEASE版易程序时将被跳过，本类型命令必须无返回值
  CT_ALLOW_APPEND_NEW_ARG    = (1 shl 5);  // 在本命令的参数表的末尾是否可以添加新的参数，新参数等同于参数表中的最后一个参数
  CT_RETURN_ARRAY_DATA       = (1 shl 6);  // 用于说明m_dtRetType，是否返回数组数据
  CT_IS_OBJ_COPY_CMD         = (1 shl 7);
  // 说明本命令为某数据类型的复制函数(执行将另一同类型数据类型数据复制到本对象时所需要的
  // 额外操作，在编译此数据类型对象的赋值语句时编译器先释放该对象的原有内容，然后生成调用此
  // 命令的代码，而不会再生成其它任何常规赋值及复制代码)。
  // !!! 1、此命令必须仅接受一个同数据类型参数而且不返回任何数据。
  //     2、执行本命令时对象的内容数据为未初始化状态，命令内必须负责初始化其全部成员数据。
  //     3、所提供过来的待复制数据类型参数数据可能为全零状态（由编译器自动生成的对象初始代码设置），
  // 复制时需要对此情况进行区别处理。
  CT_IS_OBJ_FREE_CMD         = (1 shl 8);
  // 说明本命令为某数据类型的析构函数(执行当该数据类型数据销毁时所需要的全部操作，
  // 当对象超出其作用区域时编译器仅仅生成调用此命令的代码，而不会生成任何常规销毁代码)。
  // !!! 1、此命令必须没有任何参数而且不返回任何数据。
  //     2、此命令被执行时对象的内容数据可能为全零状态（由编译器自动生成的对象初始代码设置），
  // 释放时需要对此情况进行区别处理。
  CT_IS_OBJ_CONSTURCT_CMD    = (1 shl 9);
  // 说明本命令为某数据类型的构造函数(执行当该数据类型数据初始化时所需要的全部操作，
  // !!! 1、此命令必须没有任何参数而且不返回任何数据。
  //     2、此命令被执行时对象的内容数据为全零状态。
  //     3、指定类型成员（复合数据类型成员、数组成员），必须按照对应格式继续进行下一步初始化。

  //_CMD_OS(os) // 说明该命令所支持的操作系统。注：_CMD_OS()是一个函数，用作转换os类型以便加入到CMD_INFO.m_wState。

  // 命令的难度等级(m_shtUserLevel)
  LVL_SIMPLE    = 1;  // 初级
  LVL_SECONDARY = 2;  // 中级
  LVL_HIGH      = 3;  // 高级

  //////////////////////////////////////////////////////////////////////////////

type
  pLIB_DATA_TYPE_ELEMENT = ^LIB_DATA_TYPE_ELEMENT;
  LIB_DATA_TYPE_ELEMENT  = record
    m_dtDataType : DATA_TYPE ; // 本数据成员的数据类型。
    m_pArySpec   : PByte;      // 如果本成员为数组，则本成员提供数组指定串，否则此值为NULL。数组指定串的格式为：首先为一个Byte记录该数组的维数（如果为0表示不为数组，最大值为0x7f），然后为对应数目的Integer值顺序记录对应维的元素数目。
    m_szName     : PChar;      // 本数据成员的名称，如果本数据成员所属的数据类型只有这一个数据成员，此值应该为NULL。
    m_szEGName   : PChar;      // 本数据成员的英文名称，可以为空或NULL。
    m_szExplain  : PChar;      // 本数据成员的详细说明。

    m_dwState    : LongWord;   // 状态值，见下面的常量定义。
    m_nDefault   : Integer;    // 默认值，!!! 如果位于枚举数据类型中，则本成员为具体的枚举数值。

    ////////////////////////////////////////////////////////////////////////////
    //
    // 其中，m_dwState可取以下值的组合：
    //   LES_HAS_DEFAULT_VALUE = (1 shl 0);  // 本数据成员有默认值，默认值在m_nDefault中说明。
    //   LES_HIDED             = (1 shl 1);  // 本子数据成员被隐藏。
    // 
    // 关于数据成员的默认值(m_nDefault)：
    //
    //   1、数值型：直接为数值（如为小数，只能指定其整数部分，如为长整数，只能指定不超过INT限值的部分）；
    //   2、逻辑型：1 代表真，0 代表假；
    //   3、文本型：本变量此时为PChar指针，指向默认文本串；
    //   4、其它所有类型参数一律无默认指定值。
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于LIB_DATA_TYPE_ELEMENT结构的m_dwState成员

  LES_HAS_DEFAULT_VALUE = (1 shl 0);  // 本数据成员有默认值，默认值在m_nDefault中说明。
  LES_HIDED             = (1 shl 1);  // 本子数据成员被隐藏。

type
  //////////////////////////////////////////////////////////////////////////////
  // “窗口单元属性”：UNIT_PROPERTY

  pUNIT_PROPERTY = ^UNIT_PROPERTY;
  UNIT_PROPERTY  = record
    m_szName     : PChar;     // 属性名称，注意为利于在属性表中同时设置多对象的属性，相同意义属性的名称最好一致。
    m_szEGName   : PChar;     // 英文名称。
    m_szExplain  : PChar;     // 属性解释。
    m_shtType    : SmallInt;  // 属性的数据类型，见下面的常量定义
    m_wState     : Word;      // 状态值，见下面的常量定义，同时必须使用函数_PROP_OS(os)声明该属性所支持的操作系统。
    m_szzPickStr : PChar;     // 顺序记录以"\0"分隔的所有备选文本（除开UD_FILE_NAME为所说明的特殊格式），最后以一个"\0"结束。当m_nType为UD_PICK_INT、UD_PICK_TEXT、UD_EDIT_PICK_TEXT、UD_FILE_NAME时不能为NULL。当m_nType为UD_PICK_SPEC_INT时，每一项备选文本的格式为 数值文本 + "\0" + 说明文本 + "\0" 。
  end;

  function _PROP_OS(os: LongWord): Word; //用作转换os类型以便加入到m_wState。
  function _TEST_PROP_OS(m_wState: Word; os: LongWord): boolean; //用作测试指定属性是否支持指定操作系统。

  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于UNIT_PROPERTY结构的m_shtType和m_wState成员

  // “窗口单元属性”的数据类型(m_shtType)
  UD_PICK_SPEC_INT    = 1000;  // 数据为INT值，用户只能选择，不能编辑。
  UD_INT              = 1001;  // 数据为INT值
  UD_DOUBLE           = 1002;  // 数据为DOUBLE值
  UD_BOOL             = 1003;  // 数据为BOOL值
  UD_DATE_TIME        = 1004;  // 数据为DATE值
  UD_TEXT             = 1005;  // 数据为字符串
  UD_PICK_INT         = 1006;  // 数据为INT值，用户只能选择，不能编辑。
  UD_PICK_TEXT        = 1007;  // 数据为待选字符串，用户只能选择，不能编辑。
  UD_EDIT_PICK_TEXT   = 1008;  // 数据为待选字符串，用户可以编辑。
  UD_PIC              = 1009;  // 为图片文件数据
  UD_ICON             = 1010;  // 为图标文件数据
  UD_CURSOR           = 1011;  // 第一个INT记录鼠标指针类型，具体值见Windows API的LoadCursor函数。如为-1，则为自定义鼠标指针，此时后跟相应长度的鼠标指针文件内容。
  UD_MUSIC            = 1012;  // 为声音文件数据
  UD_FONT             = 1013;  // 为一个LOGFONT数据结构，不能再改。
  UD_COLOR            = 1014;  // 数据为COLORREF值。
  UD_COLOR_TRANS      = 1015;  // 数据为COLORREF值，允许透明颜色(用CLR_DEFAULT代表，CLR_DEFAULT在VC++的COMMCTRL.H头文件中定义)。
  UD_FILE_NAME        = 1016;  // 数据为文件名字符串。此时m_szzPickStr中的数据为：对话框标题 + "\0" + 文件过滤器串 + "\0" + 默认后缀 + "\0" + "1"（取保存文件名）或"0"（取读入文件名）+ "\0" 。
  UD_COLOR_BACK       = 1017;  // 数据为COLORREF值，允许系统默认背景颜色(用CLR_DEFAULT代表)。
  //UD_ODBC_CONNECT_STR = 1021;  // ODBC数据连接文本
  //UD_ODBC_SELECT_STR  = 1022;  // ODBC数据查询SQL文本
  UD_IMAGE_LIST       = 1023;  // 图片组，数据结构为
    {  #define	IMAGE_LIST_DATA_MARK	(MAKELONG ('IM', 'LT'))
	/*
	DWORD: 标志数据：为 IMAGE_LIST_DATA_MARK
	COLORREF: 透明颜色（可以为CLR_DEFAULT）
	后面为图片组数据，用CImageList::Read和CImageList::Write读写。
	*/
    }
  UD_CUSTOMIZE        = 1024;  // 自定义类型属性

  // “窗口单元属性”的状态值(m_wState)
  UW_HAS_INDENT  = (1 shl 0);  // 在属性表中显示时向外缩进一段，一般用于子属性。
  UW_GROUP_LINE  = (1 shl 1);  // 在属性表中本属性下显示分组底封线。
  UW_ONLY_READ   = (1 shl 2);  // 只读属性，设计时不可用，运行时不能写。
  UW_CANNOT_INIT = (1 shl 3);  // 设计时不可用，但运行时可以正常读写。与上标志互斥。
  UW_IS_HIDED    = (1 shl 4);  // 隐藏但可用。3.2 新增。
  //_PROP_OS(os)   // 说明该属性所支持的操作系统。_PROP_OS()是一个函数，用作转换os类型以便加入到m_wState。

  //////////////////////////////////////////////////////////////////////////////

const
  // 固定属性的数目
  FIXED_WIN_UNIT_PROPERTY_COUNT = 8;

  // 每个固定属性定义
  FIXED_WIN_UNIT_PROPERTY : array[0..FIXED_WIN_UNIT_PROPERTY_COUNT-1] of UNIT_PROPERTY =
   (( m_szName: PChar('左边');     m_szEGName: PChar('left');         m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('顶边');     m_szEGName: PChar('top');          m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('宽度');     m_szEGName: PChar('width');        m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('高度');     m_szEGName: PChar('height');       m_szExplain: nil; m_shtType: UD_INT;    m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('标记');     m_szEGName: PChar('tag');          m_szExplain: nil; m_shtType: UD_TEXT;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('可视');     m_szEGName: PChar('visible');      m_szExplain: nil; m_shtType: UD_BOOL;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('禁止');     m_szEGName: PChar('disable');      m_szExplain: nil; m_shtType: UD_BOOL;   m_wState: (OS_ALL shr 16); m_szzPickStr: nil ),
    ( m_szName: PChar('鼠标指针'); m_szEGName: PChar('MousePointer'); m_szExplain: nil; m_shtType: UD_CURSOR; m_wState: (OS_ALL shr 16); m_szzPickStr: nil ));

  // 注：(OS_ALL shr 16) 即 _PROP_OS(OS_ALL)  // 固定属性支持所有操作系统
  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // “事件参数信息”EVENT_ARG_INFO结构 //3.2 及以后使用第二个版本EVENT_ARG_INFO2

  pEVENT_ARG_INFO = ^EVENT_ARG_INFO;
  EVENT_ARG_INFO  = record
    m_szName    : PChar;  // 参数名称
    m_szExplain : PChar;  // 参数详细解释
    m_dwState   : Word;   // 状态值，见下面的常量定义（const EAS_IS_BOOL_ARG = (1 shl 0);）
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于在EVENT_ARG_INFO结构的m_dwState成员

  EAS_IS_BOOL_ARG = (1 shl 0); // 为逻辑型参数，如无此标志，则认为是整数型参数

type
  //////////////////////////////////////////////////////////////////////////////
  // “事件信息”EVENT_ARG_INFO结构 //3.2 及以后使用第二个版本EVENT_ARG_INFO2

  pEVENT_INFO = ^EVENT_INFO;
  EVENT_INFO  = record
    m_szName        : PChar;           // 事件名称
    m_szExplain     : PChar;           // 事件详细解释
    m_dwState       : Longword;        // 状态值，见下面的常量及函数定义
    m_nArgCount     : Integer;         // 事件的参数数目
    m_pEventArgInfo : PEVENT_ARG_INFO; // 事件参数
  end;

  function _EVENT_OS(os: LongWord): LongWord; // 用作转换os类型以便加入到m_dwState
  function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean; // 用作测试指定事件是否支持指定操作系统

  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于EVENT_INFO结构的m_dwState成员

  EV_IS_HIDED    = (1 shl 0);  // 本事件是否为隐含事件（即不能被一般用户所使用或被废弃但为了保持兼容性又要存在的事件）。
  //EV_IS_MOUSE_EVENT = (1 shl 1); //已废弃
  EV_IS_KEY_EVENT= (1 shl 2);
  EV_RETURN_INT  = (1 shl 3);  // 本事件的处理子程序需要返回一个整数值，与下标志互斥。
  EV_RETURN_BOOL = (1 shl 4);  // 本事件的处理子程序需要返回一个逻辑值，与上标志互斥。
  //_EVENT_OS(os)  // 声明本事件所支持的操作系统。_EVENT_OS()是一个函数，用作转换os类型以便加入到m_dwState。

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // “事件参数信息”EVENT_ARG_INFO2结构 //3.2 及以后使用

  pEVENT_ARG_INFO2 = ^EVENT_ARG_INFO2;
  EVENT_ARG_INFO2  = record
    m_szName    : PChar;      // 参数名称
    m_szExplain : PChar;      // 参数详细解释
    m_dwState   : Word;       // 状态值，见下面的常量定义（const EAS_BY_REF = (1 shl 1);）
    m_dtDataType: DATA_TYPE;  // 参数类型
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于在EVENT_ARG_INFO2结构的m_dwState成员

  EAS_BY_REF = (1 shl 1); // 是否需要以参考方式传值，如果置位，则支持库中抛出事件的代码必须确保其能够被系统所访问（即分配内存的方法和数据的格式必须符合要求）。

type
  //////////////////////////////////////////////////////////////////////////////
  // “事件信息”EVENT_ARG_INFO2结构 //3.2 及以后使用

  pEVENT_INFO2 = ^EVENT_INFO2;
  EVENT_INFO2  = record
    m_szName        : PChar;            // 事件名称
    m_szExplain     : PChar;            // 事件详细解释
    m_dwState       : Longword;         // 状态值，见下面的常量定义
    m_nArgCount     : Integer;          // 事件的参数数目
    m_pEventArgInfo : PEVENT_ARG_INFO2; // 事件参数
    m_dtRetDataType : DATA_TYPE;        // 事件返回值类型，//!!! 如果该数据类型有额外的数据需要释放，需要由支持库中抛出事件的代码负责将其释放。
  end;

  //function _EVENT_OS(os: LongWord): LongWord; // 用作转换os类型以便加入到m_dwState
  //function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean; // 用作测试指定事件是否支持指定操作系统
  //////////////////////////////////////////////////////////////////////////////

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于EVENT_INFO2结构的m_dwState成员

  //EV_IS_HIDED    = (1 shl 0);  // 本事件是否为隐含事件（即不能被一般用户所使用或被废弃但为了保持兼容性又要存在的事件）。
  //EV_IS_KEY_EVENT= (1 shl 2);
  //以上两常量(可在EVENT_INFO中使用)前面已定义
  EV_IS_VER2       = (1 shl 31); // 表示本结构为EVENT_INFO2，!!!使用本结构时必须加上此状态值。
  //_EVENT_OS(os)  // 声明本事件所支持的操作系统。_EVENT_OS()是一个函数，用作转换os类型以便加入到m_dwState。

  //////////////////////////////////////////////////////////////////////////////


type HUNIT = LongWord;

type PFN_INTERFACE = procedure(); stdcall;  // 通用接口指针


const
  //////////////////////////////////////////////////////////////////////////////
  // 窗口单元对外接口ID

  ITF_CREATE_UNIT             = 1;  // 创建组件

  // 下面两个接口仅在可视化设计窗口界面时使用。
  ITF_PROPERTY_UPDATE_UI      = 2;  // 说明属性目前可否被修改
  ITF_DLG_INIT_CUSTOMIZE_DATA = 3;  // 使用对话框设置自定义数据

  ITF_NOTIFY_PROPERTY_CHANGED = 4;  // 通知某属性数据被修改
  ITF_GET_ALL_PROPERTY_DATA   = 5;  // 取全部属性数据
  ITF_GET_PROPERTY_DATA       = 6;  // 取某属性数据
  ITF_GET_ICON_PROPERTY_DATA  = 7;  // 取窗口的图标属性数据（仅用于窗口）
  ITF_IS_NEED_THIS_KEY        = 8;  // 询问单元是否需要指定的按键信息，用作窗口单元截获处理默认为运行时环境处理的按键，如TAB、SHIFT+TAB、UP、DOWN等。
  ITF_LANG_CNV                = 9;  // 组件数据语言转换
  //没有10
  ITF_MSG_FILTER              = 11; // 消息过滤
  ITF_GET_NOTIFY_RECEIVER     = 12; // 取组件的附加通知接收者(PFN_ON_NOTIFY_UNIT)

type

  PFN_GET_INTERFACE = function (nInterfaceNO: Integer) : PFN_INTERFACE; stdcall;

  //////////////////////////////////////////////////////////////////////////////
  // 接口：

  // 创建单元，成功时返回HUNIT，失败返回NULL。
  PFN_CREATE_UNIT = function (
    pAllPropertyData     : PByte;      // 指向本窗口单元的已有属性数据，由本窗口单元的
    nAllPropertyDataSize : Integer;    // 提供pAllPropertyData所指向数据的尺寸，如果没有则为0。
    dwStyle        : LongWord;         // 预先设置的窗口风格。
    hParentWnd     : LongWord;         // 父窗口句柄。
    uID            : LongWord;         // 在父窗口中的ID。
    hMenu          : LongWord;         // 未使用。
    x, y           : Integer;          // 位置
    cx, cy         : Integer;          // 尺寸
    dwWinFormID    : LongWord;         // 本窗口单元所在窗口的ID，用作通知到系统。
    dwUnitID       : LongWord;         // 本窗口单元的ID，用作通知到系统。
    hDesignWnd     : LongWord = 0;     // 如果blInDesignMode为真，则hDesignWnd提供所设计窗口的窗口句柄。
    blInDesignMode : EBool = EFalse    // 说明是否被易语言IDE调用以进行可视化设计，运行时为假。
  ) : LongWord; stdcall;

  //组件数据语言转换，返回包含转换后组件数据的HGLOBAL(LongWord)句柄，失败返回nil。
  PFN_CNV = procedure (
    ps      : PChar;
    dwState : LongWord;
    nParam  : Integer
  ); stdcall;

const
  // 函数指针PFN_CNV中的dwState参数可以为以下值的组合。
  CNV_NULL     = 0;
  CNV_FONTNAME = 1;  // 为转换字体名的语言(由于可能变长，ps中必须保证有足够的空间存放转换后的字体名)。

type
  // 组件数据语言转换，返回包含转换后组件数据的HGLOBAL(LongWord)句柄，失败返回nil。
  PFN_LANG_CNV = function (
    pAllData      : PByte;
    pnAllDataSize : PInteger;
    fnCnv         : PFN_CNV;
    nParam        : Integer  // nParam必须原值传递给fnCnv的对应参数。
  ) : LongWord; stdcall;

  // 以下函数仅在设计时使用。

  // 如果指定属性目前可以被操作，返回真，否则返回假。
  PFN_PROPERTY_UPDATE_UI = function (
    hUnit          : LongWord;         // 由PFN_CREATE_UNIT返回的已创建窗口单元的句柄，下同。
    nPropertyIndex : Integer           // 所需要查询属性的索引值，下同。
  ) : EBool; stdcall;

  // 用作设置类型为UD_CUSTOMIZE的单元属性。如果需要重新创建该单元才能修改单元外形，请返回真。
  PFN_DLG_INIT_CUSTOMIZE_DATA = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;
    pblModified    : PEBool= nil;   // 如果pblModified不为nil，请在其中返回是否被用户真正修改（便于易语言IDE建立UNDO记录）。
    pReserved      : Pointer = nil     // 保留未用。LPVOID
  ) : EBool; stdcall;

type
  // 临时结构，仅在UNIT_PROPERTY_VALUE结构中用于定义m_data成员
  T_UNIT_PROPERTY_VALUE__m_data  = record
    m_pData     : PByte;
    m_nDataSize : Integer;
  end;

  // 用作记录某属性的具体属性值。 (In C/C++, UNIT_PROPERTY_VALUE is defined as an UNION)
  pUNIT_PROPERTY_VALUE = ^UNIT_PROPERTY_VALUE;
  UNIT_PROPERTY_VALUE  = record
    case Integer of
      0: (m_int        : Integer);   // 对应的属性类别：UD_INT、UD_PICK_INT，下同。
      1: (m_double     : Double);    // UD_DOUBLE
      3: (m_bool       : EBool);     // UD_BOOL
      4: (m_dtDateTime : TDateTime); // UD_DATE_TIME
      5: (m_clr        : Longword);  // UD_COLOR、UD_COLOR_TRANS、UD_COLOR_BACK
      6: (m_szText     : PChar);     // UD_TEXT、UD_PICK_TEXT、UD_EDIT_PICK_TEXT、UD_ODBC_CONNECT_STR、UD_ODBC_SELECT_STR
      7: (m_szFileName : PChar);     // UD_FILE_NAME
      8: (m_data : T_UNIT_PROPERTY_VALUE__m_data); // UD_PIC、UD_ICON、UD_CURSOR、UD_MUSIC、UD_FONT、UD_CUSTOMIZE、UD_IMAGE_LIST
  end;

  // 通知某属性（非UD_CUSTOMIZE类别属性）数据被用户修改，需要根据该修改相应更改内部数据及外形，如果确实需要重新创建才能修改单元外形，请返回真。注意：必须进行所传入值的合法性校验。
  PFN_NOTIFY_PROPERTY_CHANGED = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;               // 第几个属性被修改，从0开始(不计基本属性)，下同
    pPropertyValue : PUNIT_PROPERTY_VALUE;  // 用作修改的相应属性数据。
    ppszTipText    : PPChar = nil           // 目前尚未使用。LPTSTR*
  ) : EBool; stdcall;

  // 取某属性数据到pPropertyValue中，成功返回真，否则返回假。注意：如果在设计时（由调用PFN_CREATE_UNIT时的blInDesignMode参数决定），pPropertyValue必须返回所存储的值。如果在运行时（blInDesignMode为假），必须返回实际的当前实时值。比如说，编辑框窗口单元的“内容”属性，设计时必须返回内部所保存的值，而运行时就必须调用GetWindowText去实时获取。
  PFN_GET_PROPERTY_DATA = function (
    hUnit          : LongWord;
    nPropertyIndex : Integer;
    pPropertyValue : pUNIT_PROPERTY_VALUE  // 用作接收欲读取属性的数据。
  ) : EBool; stdcall;

  // 返回本窗口单元的全部属性数据，由该窗口单元的实现代码自行设计格式将所有属性数据组合到一起。此窗口单元的PFN_CREATE_UNIT接口必须能够正确解读此数据。
  PFN_GET_ALL_PROPERTY_DATA = function (hUnit : LongWord) : LongWord; stdcall;  // 在Delphi中, HGLOBAL=THandle=LongWord;

  // 取窗口的图标属性数据（仅用于窗口）
  PFN_GET_ICON_PROPERTY_DATA = function (pAllData:PByte; nAllDataSize:Integer): LongWord; stdcall;

  // 询问单元是否需要指定的按键信息，如果需要，返回真，否则返回假。
  PFN_IS_NEED_THIS_KEY = function (hUnit : LongWord; wKey : Word) : EBool; stdcall;

  // 消息过滤(仅对消息过滤窗口组件有效,即具有LDT_MSG_FILTER_CONTROL标记)，被过滤掉返回真，否则返回假。
  PFN_MESSAGE_FILTER = function (pMsg: Pointer): EBool; // Windows操作系统中pMsg为指向TMsg的指针。

  // 附加通知处理函数, 参数nMsg取值为 NU_* 系统常量
	PFN_ON_NOTIFY_UNIT = function (nMsg: Integer; dwParam1: DWord = 0; dwParam2: DWord = 0): Integer; stdcall;

const
  // 以下定义 PFN_ON_NOTIFY_UNIT 可接收的通知值及其参数值
	NU_GET_CREATE_SIZE_IN_DESIGNER = 0; // 取设计时组件被单击放置到窗体上时的默认创建尺寸。dwParam1: 类型: INT*, 返回宽度(单位像素); dwParam2: 类型: INT*, 返回高度(单位像素)。成功返回1,失败返回0。

const

  UNIT_BMP_SIZE       = 24;       // 单元标志位图的宽度和高度。
  UNIT_BMP_BACK_COLOR = $C0C0C0;  // 单元标志位图的背景颜色(灰色): RGB(192,192,192)=$C0C0C0=12632256

type
  //////////////////////////////////////////////////////////////////////////////
  // “库定义数据类型” LIB_DATA_TYPE_INFO

  pLIB_DATA_TYPE_INFO = ^LIB_DATA_TYPE_INFO;
  LIB_DATA_TYPE_INFO  = record
    m_szName      : PChar;     // 名称
    m_szEGName    : PChar;     // 英文名称，可为空或nil
    m_szExplain   : PChar;     // 详细解释，如无则可为nil

    m_nCmdCount   : Integer;   // 本数据类型成员方法的数目（可为0）
    m_pnCmdsIndex : PInteger;  // 顺序记录本类型中所有成员方法命令在支持库命令表中的索引值，可为NULL。
    m_dwState     : LongWord;  // 状态值，见下面的说明，及常量和函数定义

    // 以下成员只有在为窗口单元、菜单时才有效。
    m_dwUnitBmpID    : LongWord;       // 指定在支持库中的单元图像资源ID（注意不同于上面的图像索引），0为无。尺寸必须为24*24 ，背景颜色为RGB(192,192,192) 。
    m_nEventCount    : Integer;        // 本单元的事件数目
    m_pEventBegin    : pEVENT_INFO ;   // 定义本单元的所有事件
    m_nPropertyCount : Integer;        // 本单元的属性数目
    m_pPropertyBegin : pUNIT_PROPERTY; // 定义本单元的所有属性

    // 用作提供本窗口单元的所有接口。
    m_pfnGetInterface : PFN_GET_INTERFACE;

    // 以下成员只有在不为窗口单元、菜单时才有效。
    m_nElementCount : Integer;                 // 本数据类型中子成员的数目（可为0）。如为窗口、菜单单元，此变量值必为0。
    m_pElementBegin : pLIB_DATA_TYPE_ELEMENT;  // 指向子成员数组的首地址。

    ////////////////////////////////////////////////////////////////////////////
    //
    // 其中，m_dwState 可以为以下常量值和函数值的组合：
    //   LDT_IS_HIDED             = (1 shl 0);  // 本类型是否为隐含类型（即不能由用户直接用作定义的类型，如被废弃但为了保持兼容性又要存在的类型）
    //   LDT_IS_ERROR             = (1 shl 1);  // 本类型在本库中不能使用，具有此标志一定隐含。即使具有此标志，本类型的类型数据也必须完整定义。
    //   LDT_MSG_FILTER_CONTROL   = (1 shl 5);  // 是否为消息过滤组件。
    //   LDT_WIN_UNIT             = (1 shl 6);  // 是否为窗口单元，如此标志置位则m_nElementCount必为0
    //   LDT_IS_CONTAINER         = (1 shl 7);  // 是否为容器型窗口单元，如有此标志，LDT_WIN_UNIT必须置位。
    //   LDT_IS_FUNCTION_PROVIDER = (1 shl 15); // 是否为仅用作提供功能的窗口单元（如时钟），如此标志置位则LDT_WIN_UNIT必置位。具有此标志的单元在运行时无可视外形。
    //   LDT_CANNOT_GET_FOCUS     = (1 shl 16); // 仅用作窗口单元，如此标志置位则表示此单元不能接收输入焦点，不能TAB键停留。
    //   LDT_DEFAULT_NO_TABSTOP   = (1 shl 17); // 仅用作窗口单元，如此标志置位则表示此单元可以接收输入焦点，但默认不停留TAB键，本标志与上标志互斥。
    //   LDT_BAR_SHAPE            = (1 shl 20); // 是否为需要自调整位置或尺寸的条状窗口单元（如工具条、状态条等），对于具有此标志的单元，所在窗口尺寸改变后易语言运行时环境会自动发送给WU_SIZE_CHANGED消息。注意：条状窗口单元如果需要自动顶部对齐必须具有 CCS_TOP 窗口风格，如果需要自动底部对齐必须具有 CCS_BOTTOM 窗口风格。
    //   LDT_ENUM                 = (1 shl 22); // 是否为枚举数据类型。3.7新增。
    //   _DT_OS(os)   //声明该数据类型所支持的操作系统。_DT_OS()是一个函数，用作转换os类型以便加入到m_dwState。
    //
    // 对于 m_dwState具有LDT_BAR_SHAPE标志的单元，所在窗口尺寸改变后易语言运行时环境会自动发送给WU_SIZE_CHANGED消息。
    // 注意，条状窗口单元如果需要自动顶部对齐必须具有CCS_TOP窗口风格，如果需要自动底部对齐必须具有CCS_BOTTOM窗口风格。
    //
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _DT_OS(os: LongWord): LongWord;  // 用作转换os类型以便加入到m_dwState
  function _TEST_DT_OS(m_dwState,os: LongWord): boolean; // 用作测试指定数据类型是否支持指定操作系统

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量用于LIB_DATA_TYPE_INFO结构的m_dwState成员中

  LDT_IS_HIDED             = (1 shl 0);  // 本类型是否为隐含类型（即不能由用户直接用作定义的类型，如被废弃但为了保持兼容性又要存在的类型）
  LDT_IS_ERROR             = (1 shl 1);  // 本类型在本库中不能使用，具有此标志一定隐含。即使具有此标志，本类型的类型数据也必须完整定义。

  LDT_MSG_FILTER_CONTROL   = (1 shl 5);  // 是否为消息过滤组件。
  LDT_WIN_UNIT             = (1 shl 6);  // 是否为窗口单元，如此标志置位则m_nElementCount必为0
  LDT_IS_CONTAINER         = (1 shl 7);  // 是否为容器型窗口单元，如有此标志，LDT_WIN_UNIT必须置位。

  LDT_IS_FUNCTION_PROVIDER = (1 shl 15); // 是否为仅用作提供功能的窗口单元（如时钟），如此标志置位则LDT_WIN_UNIT必置位。具有此标志的单元在运行时无可视外形。
  LDT_CANNOT_GET_FOCUS     = (1 shl 16); // 仅用作窗口单元，如此标志置位则表示此单元不能接收输入焦点，不能TAB键停留。
  LDT_DEFAULT_NO_TABSTOP   = (1 shl 17); // 仅用作窗口单元，如此标志置位则表示此单元可以接收输入焦点，但默认不停留TAB键，本标志与上标志互斥。

  // 新版中没有了LDT_BAR_SHAPE的定义，不知是有意还是无意。此处依然保留以兼容旧版。
  LDT_BAR_SHAPE            = (1 shl 20); // 是否为需要自调整位置或尺寸的条状窗口单元（如工具条、状态条等），对于具有此标志的单元，所在窗口尺寸改变后易语言运行时环境会自动发送给WU_SIZE_CHANGED消息。注意：条状窗口单元如果需要自动顶部对齐必须具有CCS_TOP窗口风格，如果需要自动底部对齐必须具有CCS_BOTTOM窗口风格。
  LDT_ENUM                 = (1 shl 22); // 是否为枚举数据类型。3.7新增。

  //_DT_OS(os)  // 声明该数据类型所支持的操作系统。_DT_OS()是一个函数，用作转换os类型以便加入到m_dwState。

  //////////////////////////////////////////////////////////////////////////////

type

  //////////////////////////////////////////////////////////////////////////////
  // “库常量”数据结构 Lib_Const_Info

  pLIB_CONST_INFO = ^LIB_CONST_INFO;
  LIB_CONST_INFO  = record

    m_szName       : PChar;     // 常量名称
    m_szEGName     : PChar;     // 常量英文名称，可以为空或nil
    m_szExplain    : PChar;     // 详细解释

    m_shtReserved  : Smallint;  // 必须为 1 。
    m_shtType      : Smallint;  // 常量类型，取值为CT_NULL,CT_NUM,CT_BOOL,CT_TEXT之一，见下面的说明和常量定义
    m_szText       : PChar;     // 文本（当m_shtType取值为CT_TEXT时）
    m_dbValue      : Double;    // 数值（当m_shtType取值为CT_NUM、CT_BOOL时）
    ////////////////////////////////////////////////////////////////////////////
    // 其中，m_shtType 可以取以下常量值之一：
    //   CT_NULL  = 0;  // 空值
    //   CT_NUM   = 1;  // 数值型，如: 3.14159
    //   CT_BOOL  = 2;  // 逻辑型，如: 1       ( 1代表'真'; 0代表'假')
    //   CT_TEXT  = 3;  // 文本型，如: 'abc'
    ////////////////////////////////////////////////////////////////////////////
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量在 LIB_CONST_INFO 结构中用到

  CT_NULL  = 0;  // 空值
  CT_NUM   = 1;	 // 数值型，如: 3.14159
  CT_BOOL  = 2;	 // 逻辑型，如: 1       ( 1代表'真'; 0代表'假')
  CT_TEXT  = 3;	 // 文本型，如: 'abc'

  //////////////////////////////////////////////////////////////////////////////

type
  //////////////////////////////////////////////////////////////////////////////
  // 常用数据结构。

  // 存放数值型数据
  pSYS_NUM_VALUE = ^SYS_NUM_VALUE;
  SYS_NUM_VALUE  = record
    case Integer of
      0: ( m_byte   : Byte);
      1: ( m_short  : SmallInt);
      2: ( m_int    : Integer);
      3: ( m_int64  : Int64);
      4: ( m_float  : Single);
      5: ( m_double : Double);
  end;

  // 标识窗口单元
  pMUNIT = ^MUNIT;
  MUNIT  = record
    m_dwFormID  : LongWord;
    m_dwUnitID  : Longword;
  end;

  //子语句
  pSTATMENT_CALL_DATA = ^STATMENT_CALL_DATA;
  STATMENT_CALL_DATA  = record
      m_dwStatmentSubCodeAdr : LongWord;   // 记录可重调用语句子程序代码的进入地址。
      m_dwSubEBP             : LongWord;   // 记录该子语句所处子程序的EBP指针，以便访问该子程序中的局部变量。
  end;


  // 临时结构，仅在MDATA_INF中用于定义m_Value成员
  T_MDATA_INF_Data = packed record
    case Integer of
       // 第一部分。注意：当对应参数具有AS_RECEIVE_VAR或AS_RECEIVE_VAR_ARRAY或AS_RECEIVE_VAR_OR_ARRAY标志定义时将使用下面的第二部分。
    0: ( m_byte          : Byte);        // SDT_BYTE 数据类型的数据，下同。
    1: ( m_short         : SmallInt);    // SDT_SHORT
    2: ( m_int           : Integer);     // SDT_INT
    3: ( m_uint          : Longword);    // (DWORD)SDT_INT, 无符号整数型
    4: ( m_int64         : Int64);       // SDT_INT64
    5: ( m_float         : Single);      // SDT_FLOAT
    6: ( m_double        : Double);      // SDT_DOUBLE
    7: ( m_date          : TDateTime);   // SDT_DATE_TIME   (在VC中: typedef double DATE; 在Delphi中: type TDateTime = type Double;)
    8: ( m_bool          : EBool);    // SDT_BOOL  (在VC中: typedef int BOOL;)
    9: ( m_pText         : PChar);       // SDT_TEXT，经过系统预处理，即使是空文本，此指针值也不会为nil，以便于处理。指针所指向数据的格式见前面的描述。!!!为了避免修改到常量段(m_pText有可能会指向易程序常量段区域)中的数据，只可读取而不可更改其中的内容，下同。
    10:( m_pBin          : PBYTE);       // SDT_BIN，经过系统预处理，即使是空字节集，此指针值也不会为nil，以便于处理。指针所指向数据的格式见前面的描述。!!!只可读取而不可更改其中的内容。
    11:( m_dwSubCodeAdr  : LongWord);    // SDT_SUB_PTR，为子程序代码地址指针。
    12:( m_statment      : STATMENT_CALL_DATA); // 子语句。SDT_STATMENT数据类型。
    13:( m_unit          : MUNIT);       // 窗口单元、菜单数据类型的数据。
    14:( m_pCompoundData : Pointer);     // 复合数据类型数据指针，指针所指向数据的格式见前面的描述。!!! 只可读取而不可更改其中的内容。
    15:( m_pAryData      : Pointer);     // 数组数据指针，指针所指向数据的格式见前面的描述。注意如果为文本或字节集数组，则成员数据指针可能为NULL。!!! 只可读取而不可更改其中的内容。

       // 第二部分。为指向变量地址的指针，仅当参数具有AS_RECEIVE_VAR或AS_RECEIVE_VAR_ARRAY或AS_RECEIVE_VAR_OR_ARRAY标志时才被使用。
    16:( m_pByte          : ^Byte);      // SDT_BYTE 数据类型变量的地址，下同。
    17:( m_pShort         : ^SmallInt);  // SDT_SHORT
    18:( m_pInt           : ^Integer);   // SDT_INT
    19:( m_pUint          : ^Longword);  // (DWORD)SDT_INT, 无符号整数型
    20:( m_pInt64         : ^Int64);     // SDT_INT64
    21:( m_pFloat         : ^Single);    // SDT_FLOAT
    22:( m_pDouble        : ^Double);    // SDT_DOUBLE
    23:( m_pDate          : ^TDateTime); // SDT_DATE_TIME
    24:( m_pBool          : ^EBool);  // SDT_BOOL
    25:( m_ppText         : PPChar);     // SDT_TEXT，注意*m_ppText可能为NULL（代表空文本）。写入新值之前必须释放前值，例句：NotifySys (NRS_MFREE, (DWORD)*m_ppText)。!!!不可直接更改*m_ppText所指向的内容，只能释放原指针后设置入NULL（空文本）或使用NRS_MALLOC通知分配的新内存地址指针（下同）。
    26:( m_ppBin          : ^PByte);     // SDT_BIN，注意*m_ppBin可能为NULL（代表空字节集）。写入新值之前必须释放前值，例句：NotifySys (NRS_MFREE, (DWORD)*m_ppBin)。!!!不可直接更改*m_ppBin所指向的内容，只能释放原指针后设置入NULL（空字节集）或新指针。
    27:( m_pdwSubCodeAdr  : ^LongWord);  // SDT_SUB_PTR，子程序代码地址变量地址。
    28:( m_pStatment      : pSTATMENT_CALL_DATA); // 子语句。SDT_STATMENT数据类型。
    29:( m_pUnit          : ^MUNIT);     // 窗口单元、菜单数据类型变量地址。
    30:( m_ppCompoundData : ^Pointer);   // 复合数据类型变量地址。!!!注意写入新值之前必须使用NRS_MFREE通知逐一释放所有成员（即：SDT_TEXT、SDT_BIN及复合数据类型成员）及原地址指针。!!!不可直接更改*m_ppCompoundData所指向的内容，只能释放原指针后设置入新指针。
    31:( m_ppAryData      : ^Pointer);   // 数组数据变量地址，注意： 1、写入新值之前必须释放原值，例句：NotifySys (NRS_FREE_ARY,m_dtDataType, (DWORD)*m_ppAryData)，注意：此例句只适用于m_dtDataType为系统基本数据类型时的情况，如果为复合数据类型，必须根据其定义信息逐一释放。2、如果为文本或字节集数组，则其中成员的数据指针可能为NULL。!!!不可直接更改*m_ppAryData所指向的内容，只能释放原指针后设置入新指针。
  end;

  // MDATA_INF用作记录函数指针PFN_EXECUTE_CMD(命令实现函数)的返回值和参数信息
  pMDATA_INF = ^MDATA_INF;
  MDATA_INF  = packed record          // Note: packed record, it's important.
    m_Value      : T_MDATA_INF_Data;  // 数据内容（Pascal中的record不能嵌套，这是一种变通）
    m_dtDataType : DATA_TYPE;         // 数据类型，见下面的说明

    ////////////////////////////////////////////////////////////////////////////
    // 关于 m_dtDataType 的说明：
    //
    //  1、当用作传递参数数据时，如果该参数具有AS_RECEIVE_VAR_OR_ARRAY或
    //     AS_RECEIVE_ALL_TYPE_DATA标志，且为数组数据，则包含标志DT_IS_ARY，
    //     这也是DT_IS_ARY标志的唯一使用场合。
    //     DT_IS_ARY 的定义为：const DT_IS_ARY = $20000000;
    //  2、当用作传递参数数据时，如果为空白数据，则为_SDT_NULL。
    //
    ////////////////////////////////////////////////////////////////////////////
  end;
  // !!! ASSERT(sizeof(MDATA_INF)==sizeof(DWORD)*3); 结构MDATA_INF的尺寸必须等于12字节。

  ArgArray = array of MDATA_INF;  // 通常用于全局命令、的实现代码中, 辅助读取参数值。
  //如“ArgArray(pArgInf)[0].m_Value.m_int”可访问第一个参数中的integer值。


  //////////////////////////////////////////////////////////////////////////////
  // 通知用数据结构。

  // 支持库可以通知易编辑环境(IDE)或易运行环境(RUNTIME)的码值：

  PMDATA = ^MDATA;
  MDATA  = record
    m_pData     : PByte;
    m_nDataSize : Integer;
  end;
  //用于初始化MDATA结构变量。（C++的结构中可以带构造函数，而Pascal的record不可以。下同。）
  procedure Init_MDATA(var m: MDATA; pData: PByte; nDataSize: Integer);

type
  // 记录事件的来源
  pEVENT_NOTIFY = ^EVENT_NOTIFY;
  EVENT_NOTIFY  = record
    m_dwFormID    : LongWord;  // 调用ITF_CREATE_UNIT接口所传递过来的所处窗口ID（dwWinFormID参数）
    m_dwUnitID    : Longword;  // 调用ITF_CREATE_UNIT接口所传递过来的窗口单元ID（dwUnitID参数）
    m_nEventIndex : Integer;   // 事件索引（在窗口单元定义信息LIB_DATA_TYPE_INFO中m_pPropertyBegin成员中的位置）
    m_nArgCount   : Integer;   // 本事件所传递的参数数目，最多 5 个。
    m_nArgValue   : array[0..4] of Integer; // 记录各参数值，SDT_BOOL型参数值为 1 或 0。

    //!!! 注意下面两个成员在没有定义返回值的事件中无效，其值可能为任意值。
    m_blHasReturnValue : EBool; // 用户事件处理子程序处理完毕事件后是否提供了返回值。
    m_nReturnValue     : Integer;  // 用户事件处理子程序处理完毕事件后的返回值，逻辑值用数值 0（假） 和 1（真） 返回。
  end;
  //用于初始化EVENT_NOTIFY结构变量。
  procedure Init_EVENT_NOTIFY(var e: EVENT_NOTIFY;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

type
  //事件的参数值
  pEVENT_ARG_VALUE = ^EVENT_ARG_VALUE;
  EVENT_ARG_VALUE  = record
    m_inf     : MDATA_INF;  // 用于标识m_inf中是否为指针数据。
    m_dwState : LongWord;   // !!! 注意如果 m_inf.m_dtDataType 为文本型、字节集型、库定义数据类型（除开窗口单元及菜单数据类型），必须传递指针，即本标记必须置位。
    ////////////////////////////////////////////////////////////////////////////
    // 其中，m_dwState 可以取以下常量值组合：
    //   EAV_IS_POINTER = (1 shl 0)  // 表示EVENT_ARG_VALUE.m_inf中为指针数据
    //   EAV_IS_WINUNIT = (1 shl 1)  // 补充说明m_inf.m_dtDataType数据类型是否为窗口单元。!!!注意如果m_inf.m_dtDataType为窗口单元，此标记必须置位。
    ////////////////////////////////////////////////////////////////////////////
  end;
const
  //以下常量用于EVENT_ARG_VALUE结构中的m_dwState成员
  EAV_IS_POINTER = (1 shl 0);  // 表示EVENT_ARG_VALUE.m_inf中为指针数据
  EAV_IS_WINUNIT = (1 shl 1);  // 补充说明m_inf.m_dtDataType数据类型是否为窗口单元。!!!注意如果m_inf.m_dtDataType为窗口单元，此标记必须置位。

type
  // 记录事件的来源（新版）
  pEVENT_NOTIFY2 = ^EVENT_NOTIFY;
  EVENT_NOTIFY2  = record
    m_dwFormID    : LongWord;  // 调用ITF_CREATE_UNIT接口所传递过来的所处窗口ID（dwWinFormID参数）
    m_dwUnitID    : Longword;  // 调用ITF_CREATE_UNIT接口所传递过来的窗口单元ID（dwUnitID参数）
    m_nEventIndex : Integer;   // 事件索引（在窗口单元定义信息LIB_DATA_TYPE_INFO中m_pPropertyBegin成员中的位置）
    m_nArgCount   : Integer;   // 本事件所传递的参数数目，最多 12 个。
    m_nArgValue   : array[0..11] of EVENT_ARG_VALUE; // 记录各参数值

    //!!! 注意下面两个成员在没有定义返回值的事件中无效，其值可能为任意值。
    m_blHasReturnValue : EBool;  // 用户事件处理子程序处理完毕事件后是否提供了返回值。
    m_infRetData       : MDATA_INF; // 用户事件处理子程序处理完毕事件后的返回值
  end;
  //用于初始化EVENT_NOTIFY2结构变量。
  procedure Init_EVENT_NOTIFY2(var e: EVENT_NOTIFY2;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

type
  //程序图标
  pAPP_ICON = ^APP_ICON;
  APP_ICON  = record
    m_hBigIcon   : LongWord;  // 大图标句柄
    m_hSmallIcon : LongWord;  // 小图标句柄
  end;

const
  //////////////////////////////////////////////////////////////////////////////
  // 消息常量定义 (消息号)
  //
  // 注意：向系统发送消息请使用本单元中定义的NotifySys函数
  // function NotifySys (nMsg: Integer; dwParam1,dwParam2: Longword): Integer;

  // NES_ 开头的常量为仅被易编辑环境(IDE)处理的通知(消息号)。[NES: Notify Edit System]
  NES_GET_MAIN_HWND = 1;  // 取易编辑环境主窗口的句柄，可以在支持库的AddIn函数中使用。
  NES_RUN_FUNC = 2;       // 通知易编辑环境运行指定的功能，返回一个BOOL值。dwParam1为功能号；dwParam2为一个双DWORD数组指针,分别提供功能参数1和2。

  // NAS_ 开头的常量为既被易编辑环境又被易运行环境处理的通知(消息号)。[NAS: Notify All System]
  NAS_GET_APP_ICON           = 1000;  // 通知系统创建并返回程序的图标。dwParam1为pAPP_ICON指针。
  NAS_GET_LIB_DATA_TYPE_INFO = 1002;  // 返回指定库定义数据类型的pLIB_DATA_TYPE_INFO定义信息指针。dwParam1为欲获取信息的数据类型DATA_TYPE；如果该数据类型无效或者不为库定义数据类型，则返回nil，否则返回pLIB_DATA_TYPE_INFO指针。
  NAS_GET_HBITMAP            = 1003;  // 返回HBITMAP句柄。dwParam1为图片数据指针，dwParam2为图片数据尺寸。如果成功返回非NULL的HBITMAP句柄（注意使用完毕后释放），否则返回NULL。
  NAS_GET_LANG_ID            = 1004;  // 返回当前系统或运行环境所支持的语言ID
  NAS_GET_VER                = 1005;  // 返回当前系统或运行环境的版本号，LOWORD为主版本号，HIWORD为次版本号。
  NAS_GET_PATH               = 1006;  // 返回当前开发或运行环境的某一类目录或文件名，目录名以“\”结束。
    (* NAS_GET_PATH所用参数：
       dwParam1: 指定所需要的目录，可以为以下值：
         A、开发及运行环境下均有效的目录:
            1: 开发或运行环境系统所处的目录；
         B、开发环境下有效的目录(仅开发环境中有效):
            1001: 系统例程和支持库例程所在目录名
            1002: 系统工具所在目录
            1003: 系统帮助信息所在目录
            1004: 保存所有登记到系统中易模块的目录
            1005: 支持库所在的目录
            1006: 安装工具所在目录
         C、运行环境下有效的目录(仅运行环境中有效):
            2001: 用户EXE文件所处目录；
            2002: 用户EXE文件名；
       dwParam2: 接收缓冲区地址，尺寸必须为MAX_PATH。
    *)

  NAS_CREATE_CWND_OBJECT_FROM_HWND   = 1007; // 通过指定HWND句柄创建一个CWND对象，返回其指针，记住此指针必须通过调用NRS_DELETE_CWND_OBJECT来释放。dwParam1为HWND句柄。成功返回CWnd*指针，失败返回NULL
  NAS_DELETE_CWND_OBJECT             = 1008; // 删除通过NRS_CREATE_CWND_OBJECT_FROM_HWND创建的CWND对象。dwParam1为欲删除的CWnd对象指针
  NAS_DETACH_CWND_OBJECT             = 1009; // 取消通过NRS_CREATE_CWND_OBJECT_FROM_HWND创建的CWND对象与其中HWND的绑定。dwParam1为CWnd对象指针。成功返回HWND,失败返回0
  NAS_GET_HWND_OF_CWND_OBJECT        = 1010; // 获取通过NRS_CREATE_CWND_OBJECT_FROM_HWND创建的CWND对象中的HWND。dwParam1为CWnd对象指针。成功返回HWND,失败返回0
  NAS_ATTACH_CWND_OBJECT             = 1011; // 将指定HWND与通过NRS_CREATE_CWND_OBJECT_FROM_HWND创建的CWND对象绑定起来。dwParam1为HWND，dwParam2为CWnd对象指针。成功返回1,失败返回0
  NAS_IS_EWIN                        = 1014; // 如果指定窗口为易语言窗口或易语言组件，返回真，否则返回假。 dwParam1为欲测试的HWND.
  
  // NRS_ 开头的常量为仅能被易运行环境处理的通知(消息号)。[NRS: Notify Runtime System]
  NRS_UNIT_DESTROIED     = 2000; // 通知系统指定的单元已经被销毁。dwParam1为dwFormID；dwParam2为dwUnitID；
  NRS_CONVERT_NUM_TO_INT = 2001; // 转换其它数值格式到整数。dwParam1为pMDATA_INF指针，其m_dtDataType必须为数值型。返回转换后的整数值。
  NRS_GET_CMD_LINE_STR   = 2002; // 取当前命令行文本，返回命令行文本指针，有可能为空串。
  NRS_GET_EXE_PATH_STR   = 2003; // 取当前执行文件所处目录名称，返回当前执行文件所处目录文本指针。
  NRS_GET_EXE_NAME       = 2004; // 取当前执行文件名称，返回当前执行文件名称文本指针。
  NRS_GET_UNIT_PTR       = 2006; // 取单元对象指针。dwParam1为WinForm的ID；dwParam2为WinUnit的ID。成功返回有效的单元对象CWnd*指针，失败返回nil。
  NRS_GET_AND_CHECK_UNIT_PTR        = 2007; // 取单元对象指针，并检查该指针。dwParam1为WinForm的ID；dwParam2为WinUnit的ID。成功返回有效的单元对象CWnd*指针，失败自动报告运行时错误并立即退出程序。
  NRS_EVENT_NOTIFY                  = 2008; // 通知系统产生了事件。dwParam1为PEVENT_NOTIFY指针。如果返回0，表示此事件已被系统抛弃，否则表示系统已经成功传递此事件到用户事件处理子程序。
  //NRS_STOP_PROCESS_EVENT_NOTIFY     = 2009; // 通知系统暂停处理事件通知。
  //NRS_CONTINUE_PROCESS_EVENT_NOTIFY = 2010; // 通知系统继续处理事件通知。
  NRS_DO_EVENTS          = 2018; // 通知Windows系统处理所有已有事件。
  NRS_GET_UNIT_DATA_TYPE = 2022; // 取单元数据类型。dwParam1为WinForm的ID；dwParam2为WinUnit的ID。成功返回有效的DATA_TYPE，失败返回0。
  NRS_FREE_ARY           = 2023; // 释放指定数组数据。dwParam1为该数据的DATA_TYPE，只能为系统基本数据类型；dwParam2为指向该数组数据的指针。
  NRS_MALLOC             = 2024; // 分配指定空间的内存，所有与易程序交互的内存都必须使用本通知分配。dwParam1为欲需求内存字节数。dwParam2如为0，则如果分配失败就自动报告运行时错并退出程序，如不为0，则如果分配失败就返回nil。返回所分配内存的首地址。
  NRS_MFREE              = 2025; // 释放已分配的指定内存。dwParam1为欲释放内存的首地址。
  NRS_MREALLOC           = 2026; // 重新分配内存。dwParam1为欲重新分配内存尺寸的首地址；dwParam2为欲重新分配的内存字节数。返回所重新分配内存的首地址，失败自动报告运行时错并退出程序。
  NRS_RUNTIME_ERR        = 2027; // 通知系统已经产生运行时错误。dwParam1为char*指针，说明错误文本。
  NRS_EXIT_PROGRAM       = 2028; // 通知系统退出用户程序。dwParam1为退出代码，该代码将被返回到操作系统。
  //
  NRS_GET_PRG_TYPE       = 2030; // 返回当前用户程序的类型，为2（调试版）或3（发布版）。
  NRS_EVENT_NOTIFY2      = 2031; // 以第二类方式通知系统产生了事件。dwParam1为PEVENT_NOTIFY2指针。如果返回 0 ，表示此事件已被系统抛弃，否则表示系统已经成功传递此事件到用户事件处理子程序。
  NRS_GET_WINFORM_COUNT  = 2032; // 返回当前程序的窗体数目。
  NRS_GET_WINFORM_HWND   = 2033; // 返回指定窗体的窗口句柄，如果该窗体尚未被载入，返回NULL。dwParam1为窗体索引。
  NRS_GET_BITMAP_DATA    = 2034; // 返回指定HBITMAP的图片数据，成功返回包含BMP图片数据的HGLOBAL句柄，失败返回NULL。dwParam1为欲获取其图片数据的HBITMAP。
  NRS_FREE_COMOBJECT     = 2035; // 通知系统释放指定的DTP_COM_OBJECT类型COM对象。dwParam1为该COM对象的地址指针。

  //////////////////////////////////////////////////////////////////////////////
  // 易编辑环境(IDE)或易运行环境(RUNTIME)可以通知支持库的码值(消息号)：

  NL_SYS_NOTIFY_FUNCTION = 1;    // 告知支持库通知系统用的函数指针，在装载支持库前通知，可能有多次，（后通知的值应该覆盖前面所通知的值），忽略返回值。库可将此函数指针（dwParam1: PFN_NOTIFY_SYS）记录下来以便在需要时使用它通知信息到系统。
  NL_FREE_LIB_DATA       = 6;  // 通知支持库释放资源准备退出及释放指定的附加数据。
  //////////////////////////////////////////////////////////////////////////////

const
  NR_OK  =  0;
  NR_ERR = -1;
type
  // 此函数用作易编辑环境(IDE)或易运行环境(RUNTIME)通知支持库有关事件。
  PFN_NOTIFY_LIB = function(nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall; // 参数dwParam1,dwParam2如果不使用则置0

  // 此函数用作支持库通知易编辑环境(IDE)或易运行环境(RUNTIME)有关事件。
  PFN_NOTIFY_SYS = function(nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall; // 参数dwParam1,dwParam2如果不使用则置0

  //////////////////////////////////////////////////////////////////////////////
  // 所有命令和方法实现函数的原型 PFN_EXECUTE_CMD
  //
  // 说明如下：
  //   1、必须是CDECL调用方式；
  //   2、pRetData用作返回数据；
  //   3、!!!如果指定库命令返回数据类型不为_SDT_ALL，可以
  //      不填充 pRetData->m_dtDataType，如果为_SDT_ALL，则必须填写；
  //   4、pArgInf提供参数数据本身，所指向的MDATA_INF记录每个输入参数，数目等同于nArgCount。
  //////////////////////////////////////////////////////////////////////////////
  PFN_EXECUTE_CMD    = procedure(pRetData:pMDATA_INF; nArgCount:Integer; pArgInf:pMDATA_INF); cdecl;
  PPFN_EXECUTE_CMD = ^PFN_EXECUTE_CMD;

  // 运行支持库中ADDIN功能的函数
  PFN_RUN_ADDIN_FN   = function(nAddInFnIndex:Integer) :Integer; stdcall;

  // 创建库中提供的超级模板程序的函数
  PFN_SUPER_TEMPLATE = function(nTemplateIndex:Integer) :Integer; stdcall;

////////////////////////////////////////////////////
const
  LIB_FORMAT_VER = 20000101; // 库格式号。在LIB_INFO结构中使用。


type
  (*                    ***************                                       *)
  (**********************   LIB_INFO  *****************************************)
  (*                    ***************                                       *)
  //////////////////////////////////////////////////////////////////////////////
  // “支持库信息”数据结构 LIB_INFO

  pLIB_INFO = ^LIB_INFO;
  LIB_INFO  = record
    m_dwLibFormatVer         : LongWord;   // 库格式号，应该等于LIB_FORMAT_VER
    m_szGuid                 : PChar;      // 对应于本库的唯一GUID串，不能为NULL或空，相同库的所有后续版本此串都应相同。注意，此GUID字串必须使用专用工具软件生成(在Delphi内，可以通过组合键[Ctrl+Shift+G]生成一个GUID字串)，以防止出现重复。

    m_nMajorVersion          : Integer;    // 本库的主版本号，必须大于0
    m_nMinorVersion          : Integer;    // 本库的次版本号
    m_nBuildNumber           : Integer;    // 构建版本号。本版本号仅用作区分相同正式版本号的系统软件（譬如仅仅修改了几个 BUG，不值得升级正式版本的系统软件）。任何公布过给用户使用的版本其构建版本号都应该不一样。赋值时应该顺序递增。

    m_nRqSysMajorVer         : Integer;    // 所需要易语言系统的主版本号，目前应该为 3
    m_nRqSysMinorVer         : Integer;    // 所需要易语言系统的次版本号，目前应该为 0
    m_nRqSysKrnlLibMajorVer  : Integer;    // 所需要的系统核心支持库的主版本号，目前应该为 3
    m_nRqSysKrnlLibMinorVer  : Integer;    // 所需要的系统核心支持库的次版本号，目前应该为 0

    m_szName                 : PChar;      // 库名，不能为nil或空
    m_nLanguage              : Integer;    // 本库所支持的语言，目前应该为 LT_CHINESE (=1)。见下面的说明和常量定义。
    m_szExplain              : PChar;      // 有关本库的详细解释
    m_dwState                : LongWord;   // 支持库状态，见以下的说明，及常量和函数定义

    m_szAuthor               : PChar;      // 作者姓名
    m_szZipCode              : PChar;      // 邮编
    m_szAddress              : PChar;      // 地址
    m_szPhoto                : PChar;      // 电话
    m_szFax                  : PChar;      // 传真
    m_szEmail                : PChar;      // 电子邮件
    m_szHomePage             : PChar;      // 网站主页
    m_szOther                : PChar;      // 作者其它信息

    m_nDataTypeCount         : Integer;             // 本库中自定义数据类型的数目，必须等于m_pDataType所指向数组成员的数目
    m_pDataType              : pLIB_DATA_TYPE_INFO; // 本库中所有自定义数据类型的定义信息
    m_nCategoryCount         : Integer;             // 全局命令类别数目，必须等同于下面m_szzCategory成员所实际提供的数目
    m_szzCategory            : PChar;               // 全局命令类别说明表，每项为一字符串，前四位数字表示图象索引号（从1开始，0表示无）。减一后的值为指向支持库中名为"LIB_BITMAP"的BITMAP资源中某一部分16X13位图的索引。
    m_nCmdCount              : Integer;             // 本库中提供的所有命令(全局命令及对象方法)的数目(如无则为0)
    m_pBeginCmdInfo          : pCMD_INFO;           // 指向所有命令及方法的定义信息数组(如m_nCmdCount为0,则为nil)
    m_pCmdsFunc              : PPFN_EXECUTE_CMD;    // 指向每个命令的实现代码首地址，(如m_nCmdCount为0,则为nil)
    m_pfnRunAddInFn          : PFN_RUN_ADDIN_FN;    // 用作为易语言IDE提供附加功能，可为nil
    m_szzAddInFnInfo         : PChar;               // 有关AddIn功能的说明，两个字符串说明一个功能。第一个为功能名称（限20字符），第二个为功能详细介绍（限60字符），最后由两个空串结束。
    m_pfnNotify              : PFN_NOTIFY_LIB;      // 提供接收来自易语言IDE或运行环境通知信息的函数，不能为nil

    m_pfnSuperTemplate       : PFN_SUPER_TEMPLATE;  // 超级模板，暂时保留不用，为nil
    m_szzSuperTemplateInfo   : PChar;               // 为nil

    m_nLibConstCount         : Integer;             // 常量数目
    m_pLibConst              : pLIB_CONST_INFO;     // 指向常量定义数组
    m_szzDependFiles         : PChar;               // 本库正常运行所需要依赖的其他文件，在制作安装软件时将会自动带上这些文件。可为nil。

    ////////////////////////////////////////////////////////////////////////////
    // 其中，m_nLanguage 可取以下值之一：
    //   __GBK_LANG_VER     =  1;  // GBK  简体中文
    //   __ENGLISH_LANG_VER =  2;  // ENGLISH  英文
    //   __BIG5_LANG_VER    =  3;  // BIG5 繁体中文
    //
    // 其中，m_dwState 可取以下值的组合：
    //   LBS_FUNC_NO_RUN_CODE = (1 shl 2);  // 本库仅为声明库，没有对应功能的支持代码，因此不能运行。
    //   LBS_NO_EDIT_INFO     = (1 shl 3);  // 本库内无供编辑用的信息（编辑信息主要为：各种名称、解释字符串等），无法被易语言IDE加载，但可提供对易程序的运行支持。
    //   LBS_IS_DB_LIB        = (1 shl 5);  // 本库为数据库操作支持库。
    //   _LIB_OS(os)   // 声明本库所支持的操作系统。_LIB_OS()是一个函数，用作转换os类型以便加入到m_dwState。
    ////////////////////////////////////////////////////////////////////////////
  end;

  function _LIB_OS(os: LongWord): LongWord; // 用作转换os类型以便加入到m_dwState
  function _TEST_LIB_OS(m_dwState,os: LongWord): boolean; //用作测试支持库是否具有指定操作系统的版本

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量在 LIB_INFO 结构的m_dwState和m_nLanguage成员中使用

  // 支持库语言
  __GBK_LANG_VER      = 1;  // GBK  简体中文
  __ENGLISH_LANG_VER  = 2;  // ENGLISH  英文
  __BIG5_LANG_VER     = 3;  // BIG5 繁体中文

  // 支持库状态值(m_dwState)
  LBS_FUNC_NO_RUN_CODE = (1 shl 2);  // 本库仅为声明库，没有对应功能的支持代码，因此不能运行。
  LBS_NO_EDIT_INFO     = (1 shl 3);  // 本库内无供编辑用的信息（编辑信息主要为：各种名称、解释字符串等），无法被易语言IDE加载，但可提供对易程序的运行支持。
  LBS_IS_DB_LIB        = (1 shl 5);  // 本库为数据库操作支持库。
  //_LIB_OS(os)   // 声明本库所支持的操作系统。_LIB_OS()是一个函数，用作转换os类型以便加入到m_dwState。

  ////////////////////////////////////////////////////////////////////////////////


type

  PFN_GET_LIB_INFO = function() : pLIB_INFO; stdcall; // GetNewInf的函数原型
  PFN_ADD_IN_FUNC  = function() : Integer; cdecl;     // m_pfnRunAddInFn的函数原型


const
  ////////////////////////////////////////////////////////////////////////////////
  FUNCNAME_GET_LIB_INFO = 'GetNewInf';   // 取本支持库的PLIB_INFO指针的输出函数名称

  LIB_BMP_RESOURCE = 'LIB_BITMAP';  // 支持库中提供的图像资源的名称
  LIB_BMP_CX       = 16;            // 每一图像资源的宽度
  LIB_BMP_CY       = 13;            // 每一图像资源的高度
  LIB_BMP_BKCOLOR  = $FFFFFF;       // 图像资源的底色(白色): RGB(255, 255, 255)=$FFFFFF=16777215


  
  { 运行时使用 }  WM_APP = $8000;        // 定义于VC中的WinUser.h，含条件编译参数WINVER>=$0400（即Windows95及以上版本）
  WU_GET_WND_PTR         = (WM_APP + 2); // 用作支持窗口单元事件反馈。
  //WU_SIZE_CHANGED        = (WM_APP + 3); // 用作在窗口尺寸改变后通知所有条状窗口单元。
  //WU_PARENT_RELAYOUT_BAR = (WM_APP + 4); // 用作通知顶层窗口重新布局所有的 bar 单元，通常在 bar 单元改变了自身尺寸后使用。

  WU_INIT  = (WM_APP + 111); //窗口创建完毕后给窗口中每一个易语言组件窗口发送此消息

  //窗口创建完毕后,此信息被发送给所有组件以让其进行需要其他组件数据配合的初始化工作.
  //本消息与WU_INIT的区别为，在本消息处理过程中所有触发的windows消息均会得到处理，
  //而在WU_INIT处理过程中所有触发的windows消息均会被屏蔽。
  WU_INIT2  = (WM_APP + 118);

const
  //////////////////////////////////////////////////////////////////////////////
  // 以下常量在函数GetDataTypeType中用到，做为返回值类型
  DTT_IS_NULL_DATA_TYPE  = 0;
  DTT_IS_SYS_DATA_TYPE   = 1;
  DTT_IS_USER_DATA_TYPE  = 2;
  DTT_IS_LIB_DATA_TYPE   = 3;


//////////////////////////////////////////////////////////////////////////////
// 以下常量为系统核心库中的组件定义，用于在用户支持库中引用核心库中的数据类型
//
const
  DTC_WIN_FORM     = 1;
  //没有2
  DTC_MENU         = 3;
  DTC_FONT         = 4;
  DTC_EDIT         = 5;
  DTC_PIC_BOX      = 6;
  DTC_SHAPE_BOX    = 7;
  DTC_DRAW_PANEL   = 8;
  DTC_GROUP_BOX     = 9;
  DTC_LABEL        = 10;
  DTC_BUTTON       = 11;
  DTC_CHECK_BOX    = 12;
  DTC_RADIO_BOX    = 13;
  DTC_COMBO_BOX    = 14;
  DTC_LIST_BOX     = 15;
  DTC_CHKLIST_BOX  = 16;
  DTC_HSCROLL_BAR  = 17;
  DTC_VSCROLL_BAR  = 18;
  DTC_PROCESS_BAR  = 19;
  DTC_SLIDER_BAR   = 20;
  DTC_TAB               = 21;
  DTC_ANIMATE           = 22;
  DTC_DATE_TIME_PICKER  = 23;
  DTC_MONTH_CALENDAR    = 24;
  DTC_DRIVER_BOX        = 25;
  DTC_DIR_BOX           = 26;
  DTC_FILE_BOX          = 27;
  DTC_COLOR_PICKER      = 28;
  DTC_HYPER_LINKER      = 29;
  DTC_SPIN              = 30;
  DTC_COMMON_DLG        = 31;
  DTC_TIMER             = 32;
  DTC_PRINTER           = 33;
  DTC_FIELD_INF         = 34;
  DTC_HTML_VIEWER       = 35;
  DTC_UDP               = 36;
  DTC_SOCK_CLIENT       = 37;
  DTC_SOCK_SERVER       = 38;
  DTC_SERIAL_PORT       = 39;
  DTC_PRINT_INF         = 40;
  DTC_GRID              = 41;
  DTC_DATA_SOURCE       = 42;
  DTC_NPROVIDER         = 43;
  DTC_DBPROVIDER        = 44;
  DTC_RGN_BUTTON        = 45;
  DTC_ODBC_DB           = 46;
  DTC_ODBCPROVIDER      = 47;
  DTC_COM_OBJECT        = 48;
  DTC_VARIANT           = 49;
  //over
  
const               // MakeLong(XXX, 1);
  DTP_LABEL         = (DTC_LABEL        or (1 shl 16));
  DTP_WIN_FORM      = (DTC_WIN_FORM     or (1 shl 16));
  DTP_MENU          = (DTC_MENU         or (1 shl 16));
  DTP_FONT          = (DTC_FONT         or (1 shl 16));
  DTP_TAB           = (DTC_TAB          or (1 shl 16));
  DTP_DRAW_PANEL    = (DTC_DRAW_PANEL   or (1 shl 16));
  DTP_PIC_BOX       = (DTC_PIC_BOX      or (1 shl 16));
  DTP_FIELD_INF     = (DTC_FIELD_INF    or (1 shl 16));
  DTP_PRINT_INF     = (DTC_PRINT_INF    or (1 shl 16));
  DTP_ODBC_DB       = (DTC_ODBC_DB      or (1 shl 16));
  DTP_ODBCPROVIDER  = (DTC_ODBCPROVIDER or (1 shl 16));
  DTP_UDP           = (DTC_UDP          or (1 shl 16));
  DTP_SOCK_CLIENT   = (DTC_SOCK_CLIENT  or (1 shl 16));
  DTP_SOCK_SERVER   = (DTC_SOCK_SERVER  or (1 shl 16));
  DTP_SERIAL_PORT   = (DTC_SERIAL_PORT  or (1 shl 16));
  DTP_DATA_SOURCE   = (DTC_DATA_SOURCE  or (1 shl 16));
  DTP_PRINTER       = (DTC_PRINTER      or (1 shl 16));
  DTP_COM_OBJECT    = (DTC_COM_OBJECT   or (1 shl 16));
  DTP_VARIANT       = (DTC_VARIANT      or (1 shl 16));

////////////////////////////////////////////////////////////////////////////////


//==============================================================================
// 声明全局函数
//==============================================================================
  
// 接受来自易IDE的通知，以获得函数指针g_fnNotifySys(全局变量)。可将本函数的地址赋值给LIB_INFO结构的m_pfnNotify成员。
function DefaultProcessNotifyLib (nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall;

// 向易IDE系统发送信息 (使用全局函数指针g_fnNotifySys)
function NotifySys (nMsg: Integer; dwParam1: Longword = 0; dwParam2: Longword = 0): Integer;

// 触发没有参数和返回值的易语言事件
procedure NotifySimpleEvent(dwFormID, dwUnitID: LongWord; nEventIndex: Integer);

// 合成RGB颜色值
//function RGB(r, g, b: Byte): LongWord;

// 使用指定文本数据建立易程序中使用的文本数据。
function CloneTextData (ps: PChar) : PChar; overload;

// 使用指定文本数据建立易程序中使用的文本数据。nTextLen用作指定文本部分的长度（不包含结束零），如果为-1，则取ps的全部长度。
function CloneTextData (ps: PChar; nTextLen: Integer): PChar; overload;

// 使用指定数据建立易程序中使用的字节集数据。
function CloneBinData (pData: PByte; nDataSize: Integer): PByte;

// 向易IDE报告运行时错误。
procedure GReportError (szErrText: PChar);

// 向易IDE申请内存
function MMalloc (nSize: Integer): Pointer;

// 释放从易IDE申请来的内存
procedure MFree (p: Pointer);

// 返回数组的数据部分首地址及成员数目。
function GetAryElementInf (pAryData: Pointer; var pnElementCount: Integer): PByte;

// 取回数据类型的类别。
function GetDataTypeType (dtDataType: DATA_TYPE): Integer;


//从指定数据块中读取第index个整数，index取值从0开始。
function GetIntByIndex(pData : Pointer; index : Integer) : Integer;

//修改指定数据块中第index个整数，index取值从0开始。
procedure SetIntByIndex(pData : Pointer; index : Integer; value : Integer);


////////////////////////////////////////////////////////////////////////////////
//
//
//
////////////////////////////////////////////////////////////////////////////////


function GetLibInfo(): pLIB_INFO;

type PFN_FREE_LIB_DATA = procedure(); //only used in delphi

procedure DefineLib(szName,szGuid,szExplain: PChar;
                    nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                    dwState: LongWord;
                    szAuthor,szHomePage,szOther: PChar;
                    nCategoryCount: Integer; szzCategory: PChar;
                    pfnRunAddInFn: PFN_RUN_ADDIN_FN = nil; szzAddInFnInfo: PChar = nil;
                    pfnNotifyLib: PFN_NOTIFY_LIB = nil; //default to DefaultProcessNotifyLib
                    szzDependFiles: PChar = nil;
                    pfnFreeLibData: PFN_FREE_LIB_DATA = nil);

procedure DefineConst(szName,szEGName,szExplain: PChar;
                      shtType: SmallInt;
                      dbValue: Double = 0.0; szTextValue: PChar = nil);
procedure DefineIntConst(szName,szEGName,szExplain: PChar; value: Integer);
procedure DefineDoubleConst(szName,szEGName,szExplain: PChar; value: Double);
procedure DefineBoolConst(szName,szEGName,szExplain: PChar; value: EBool);
procedure DefineTextConst(szName,szEGName,szExplain: PChar; value: PChar);

function DefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                       szName,szEGName,szExplain: PChar;
                       dtRetType: DATA_TYPE; wState: Word;
                       shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                       shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                       version: DWORD = 0) : Integer;

function DefineCommand_NoArg(cmdFunc: PFN_EXECUTE_CMD;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0) : Integer;

function DefineDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;

function DefineEnumDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;

function DefineUIDatatype(szName,szEGName,szExplain: PChar;
                          dwState,dwUnitBmpID: LongWord;
                          pfnGetInterface: PFN_GET_INTERFACE = nil;
                          onCreateUnit: PFN_CREATE_UNIT = nil;
                          onGetPropertyValue: PFN_GET_PROPERTY_DATA = nil;
                          onSetPropertyValue: PFN_NOTIFY_PROPERTY_CHANGED = nil;
                          onGetAllPropertiesValue: PFN_GET_ALL_PROPERTY_DATA = nil;
                          onPropertyUpdateUI: PFN_PROPERTY_UPDATE_UI = nil;
                          onInitDlgCustomData: PFN_DLG_INIT_CUSTOMIZE_DATA = nil;
                          onGetIconPropertyValue: PFN_GET_ICON_PROPERTY_DATA = nil;
                          onIsNeedThisKey: PFN_IS_NEED_THIS_KEY = nil;
                          onLanguageConv: PFN_LANG_CNV = nil;
                          onMsgFilter: PFN_MESSAGE_FILTER = nil;
                          onNotifyUnit: PFN_ON_NOTIFY_UNIT = nil ) : Integer;

function DefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                      cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                      shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                      version: DWORD = 0) : Integer;

function DefineMethod_NoArg(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0) : Integer;

procedure DefineElement(datatypeIndex: Integer; {datatypeIndex must exist}
                        szName,szEGName,szExplain: PChar;
                        dtDataType: DATA_TYPE; pArySpec: PByte = nil;
                        dwState: LongWord = 0; nDefault: Integer = 0);

procedure DefineEnumElement(datatypeIndex: Integer; {datatypeIndex must exist}
                            szName,szEGName,szExplain: PChar;
                            nValue: Integer; dwState: LongWord = 0);

procedure DefineEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                      szName,szExplain: PChar; dwState: LongWord;
                      args: array of EVENT_ARG_INFO2;
                      dtRetDataType: DATA_TYPE);

procedure DefineProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                         szName,szEGName,szExplain: PChar;
                         shtType: SmallInt; wState: Word;
                         szzPickStr: PChar);


//procedure DefineHiddenConst(nRepeatCount: Integer = 1); //cann't hide consts
procedure DefineHiddenCommand(nRepeatCount: Integer = 1; version: DWORD = 0);
procedure DefineHiddenDatatype(nRepeatCount: Integer = 1);
procedure DefineHiddenElement(datatypeIndex: Integer; nRepeatCount: Integer = 1);
procedure DefineHiddenMethod(datatypeIndex: Integer; nRepeatCount: Integer = 1; version: DWORD = 0);
procedure DefineHiddenProperty(datatypeIndex: Integer; nRepeatCount: Integer = 1);
procedure DefineHiddenEvent(datatypeIndex: Integer; nRepeatCount: Integer = 1);


////////////////////////////////////////////////////////////////////////////////

implementation

type

  //未绑定的方法
  UnbindingMethod = record
    version: DWORD;
    datatypeIndex: Integer; //-1, if not a method
    cmdInfo: CMD_INFO;
    cmdFunc: PFN_EXECUTE_CMD;
    cmdArgs: array of ARG_INFO;
    bound: boolean;
  end;

  ADatatypeData = record
    methodCount: Integer;
    methodIndexes: array of Integer;

    eventCount: Integer;
    eventInfos: array of EVENT_INFO2; //their args refers to egdata.eventArgInfos

    propertyCount: Integer;
    propertyInfos: array of UNIT_PROPERTY;

    elementCount: Integer;
    elementInfos: array of LIB_DATA_TYPE_ELEMENT;

    interfaces: array[ITF_CREATE_UNIT{1} .. ITF_GET_NOTIFY_RECEIVER{12}] of PFN_INTERFACE;
    interfaceGetterCodes: array[0..31] of Byte; //see ECreateDatetypeInterfaceGetterFunction
  end;

  //用于存储全局数据
  ELibGlobalData = record

    //libinfo
    libInfo: LIB_INFO;

    //consts
    constCount, constInfoGrowLength: Integer;
    constInfos: array of LIB_CONST_INFO;

    //commands and it's args
    cmdCount, cmdInfoGrowLength: Integer;
    cmdInfos: array of CMD_INFO;
    cmdFuncs: array of PFN_EXECUTE_CMD;
    argCount, argInfoGrowLength: Integer;
    argInfos: array of ARG_INFO;

    //datatypes
    datatypeCount, datatypeInfoGrowLength: Integer;
    datatypeInfos: array of LIB_DATA_TYPE_INFO;
    datatypeDatas: array of ADatatypeData;
    eventArgCount, eventArgInfoGrowLength: Integer;
    eventArgInfos: array of EVENT_ARG_INFO2; //share all over the library

    //others
    fnNotifySys: PFN_NOTIFY_SYS;
    nLastNotifySysResult: Integer;
    fnFreeLibData: PFN_FREE_LIB_DATA;
    hasFixedLibInfo: boolean;

    unbindingMethodCount: Integer;
    unbindingMethods: array of UnbindingMethod;
  end;

var
  //仅内部使用, 外界尽量不要使用
  //用于存储内部数据的唯一全局变量 (使用尽可能少的全局变量)
  //关于 egdata 全局变量的使用, 请参考 DefineLib(), DefineCommand(), DefineConst(), DefineDatatype(), ...
  egdata: ELibGlobalData; 


function DefaultProcessNotifyLib (nMsg:Integer; dwParam1:LongWord=0; dwParam2:LongWord=0) :Integer; stdcall;
  var ReturnValue: Integer;
begin
  ReturnValue := NR_OK;
  case nMsg of
    NL_SYS_NOTIFY_FUNCTION:
      egdata.fnNotifySys := PFN_NOTIFY_SYS(dwParam1);
    NL_FREE_LIB_DATA:
    begin
      if Assigned(egdata.fnFreeLibData) then
        egdata.fnFreeLibData(); //invoke user procedure
    end;
    else ReturnValue := NR_ERR;
  end;
  Result := ReturnValue;
end;

// 向易IDE系统发送信息。失败返回0。
function NotifySys (nMsg: Integer; dwParam1,dwParam2: Longword): Integer;
var
  EVT: PEVENT_NOTIFY2;
begin
  Result := 0;
  Assert(Assigned(egdata.fnNotifySys), 'fnNotifySys can not be nil');
  if nMsg = NRS_EVENT_NOTIFY2 then
  begin
    EVT := PEVENT_NOTIFY2(dwParam1);
    Assert(EVT <> nil, 'dwParam1 can''t be 0!');
    if not Assigned(EVT) then exit;
    //Assert((EVT.m_dwFormID <> 0) and (EVT.m_dwUnitID <> 0), 'Form id and unit id must not be 0!');
    if (EVT.m_dwFormID = 0) or (EVT.m_dwUnitID = 0) then exit;
  end;
  if Assigned(egdata.fnNotifySys) then
    Result := egdata.fnNotifySys(nMsg, dwParam1, dwParam2);

  egdata.nLastNotifySysResult := Result;
end;

//初始化MDATA结构变量
procedure Init_MDATA(var m: MDATA; pData: PByte; nDataSize: Integer);
begin
  m.m_pData := nil;
  m.m_nDataSize := 0;
end;

//初始化EVENT_NOTIFY结构变量
procedure Init_EVENT_NOTIFY(var e: EVENT_NOTIFY;dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
begin
  with e do begin
    m_dwFormID         := dwFormID;
    m_dwUnitID         := dwUnitID;
    m_nEventIndex      := nEventIndex;
    m_nArgCount        := 0;
    m_blHasReturnValue := EFalse;
    m_nReturnValue := 0;
  end;
end;

//初始化EVENT_NOTIFY2结构变量
procedure Init_EVENT_NOTIFY2(var e: EVENT_NOTIFY2; dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
var
  I: Integer;
begin
  with e do begin
    m_dwFormID         := dwFormID;
    m_dwUnitID         := dwUnitID;
    m_nEventIndex      := nEventIndex;
    m_nArgCount        := 0;
    m_blHasReturnValue := EFalse;
    m_infRetData.m_dtDataType := _SDT_NULL;
    m_infRetData.m_Value.m_double := 0;
    for I := Low(m_nArgValue) to High(m_nArgValue) do
    with m_nArgValue[I] do
    begin
      m_dwState := 0;
      m_inf.m_dtDataType := _SDT_NULL;
      m_inf.m_Value.m_double := 0;
    end;
  end;
end;

//触发没有参数和返回值的易语言事件
procedure NotifySimpleEvent(dwFormID, dwUnitID: LongWord; nEventIndex: Integer);
var
  event: EVENT_NOTIFY2;
begin
  Init_EVENT_NOTIFY2(event, dwFormID, dwUnitID, nEventIndex);
  NotifySys(NRS_EVENT_NOTIFY2, Cardinal(@event), 0);
end;

// 使用指定文本数据建立易程序中使用的文本数据。
function CloneTextData (ps: PChar) : PChar;
var
  nTextLen: Integer;
  pd: PChar;
begin
  Result := nil;
  if (ps = nil) or (ps[0] = #0) then exit;
  nTextLen := StrLen(ps);
  pd := PChar(MMalloc(nTextLen + 1));
  Assert(pd <> nil);
  SysUtils.StrLCopy(pd, ps, nTextLen + 1);
  Result := pd;
end;

// 使用指定文本数据建立易程序中使用的文本数据。nTextLen用作指定文本部分的长度（不包含结束零），如果为-1，则取ps的全部长度。
function CloneTextData (ps: PChar; nTextLen: Integer): PChar;
var pd: PChar;
begin
  Result := nil;
  if nTextLen <= 0 then exit;
  pd := PChar(MMalloc(nTextLen + 1));
  Assert(pd <> nil);
  SysUtils.StrLCopy(pd, ps, nTextLen);
  pd[nTextLen] := #0;
  Result := pd;
end;

// 使用指定数据建立易程序中使用的字节集数据。
function CloneBinData (pData: PByte; nDataSize: Integer): PByte;
var pd: PByte;
begin
  Result := nil;
  if nDataSize=0 then exit;
  pd:= PByte(MMalloc(sizeof(Integer) * 2 + nDataSize));
  Assert(pd <> nil);
  PInteger(pd)^ := 1;
  PInteger(Integer(pd)+sizeof(Integer))^ := nDataSize;
  CopyMemory(Pointer(Integer(pd)+sizeof(Integer)*2), PChar(pData), nDataSize);
  Result:= pd;
end;

// 向易IDE报告运行时错误。
procedure GReportError (szErrText: PChar);
begin
  NotifySys(NRS_RUNTIME_ERR,LongWord(szErrText), 0);
end;

// 向易IDE申请内存
function MMalloc (nSize: Integer): Pointer;
begin
  Result:= Pointer(NotifySys(NRS_MALLOC, LongWord(nSize), 0));
end;

// 释放从易IDE申请来的内存
procedure MFree (p: Pointer);
begin
  NotifySys(NRS_MFREE,LongWord(p), 0);
end;

// 返回数组的数据部分首地址及成员数目。
function GetAryElementInf (pAryData: Pointer; var pnElementCount: Integer): PByte;
var
  pnData : PInteger;
  nArys, nElementCount : Integer;
begin
  pnData:= PInteger(pAryData);
  nArys:= pnData^;  // 取得维数。
  Inc(pnData);
  nElementCount:= 1;  // 计算成员数目。
  while (nArys > 0) do begin
    nElementCount:= nElementCount * pnData^;
    Inc(pnData);
    Dec(nArys);
  end;
  pnElementCount:= nElementCount;
  Result:= PByte(pnData);
end;

// 取回数据类型的类别。
function GetDataTypeType (dtDataType: DATA_TYPE): Integer;
var dw: Longword;
begin
  if dtDataType= _SDT_NULL then begin
    Result:= DTT_IS_NULL_DATA_TYPE;
    exit;
  end;
  dw:= dtDataType and $C0000000;
  if dw=DTM_SYS_DATA_TYPE_MASK then
    Result:= DTT_IS_SYS_DATA_TYPE
  else if dw=DTM_USER_DATA_TYPE_MASK then
    Result:= DTT_IS_USER_DATA_TYPE
  else
    Result:=DTT_IS_LIB_DATA_TYPE;
end;

{  //CWnd是MFC中的一个类
// 绝对不会返回NULL或者窗口句柄无效的CWnd*指针。
CWnd* GetWndPtr (PMDATA_INF pInf)
begin
    return (CWnd*)NotifySys (NRS_GET_AND_CHECK_UNIT_PTR,
            pInf [0].m_unit.m_dwFormID, pInf [0].m_unit.m_dwUnitID);
end;
}

//------------------------------------------------------------------------------
// 以下函数是对“操作系统类型”的操作，其中的os参数可为__OS_WIN,__OS_LINUX,__OS_UNIX的组合，或OS_ALL。
// 以下函数对应于C++版支持库开发接口中的同名“宏”。

// 用作转换os类型以便加入到CMD_INFO.m_wState
function _CMD_OS(os: LongWord): Word;
begin
  Result:= ((os) shr 16);
end;

// 用作测试指定命令是否支持指定操作系统
function _TEST_CMD_OS(m_wState: Word; os: LongWord): boolean;
begin
  Result:= ((_CMD_OS(os) and m_wState) <> 0);
end;

// 用作转换os类型以便加入到UNIT_PROPERTY.m_wState
function _PROP_OS(os: LongWord): Word;
begin
  Result:= ((os) shr 16);
end;

// 用作测试指定属性是否支持指定操作系统
function _TEST_PROP_OS(m_wState: Word; os: LongWord): boolean;
begin
  Result:= ((_PROP_OS(os) and m_wState) <> 0);
end;

// 用作转换os类型以便加入到EVENT_INFO.m_dwState或EVENT_INFO2.m_dwState
function _EVENT_OS(os: LongWord): LongWord;
begin
  Result:= ((os) shr 1);
end;

// 用作测试指定事件是否支持指定操作系统
function _TEST_EVENT_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_EVENT_OS (os) and m_dwState) <> 0)
end;

// 用作转换os类型以便加入到LIB_DATA_TYPE_INFO.m_dwState
function _DT_OS(os: LongWord): LongWord;
begin
  Result:= os;
end;

// 用作测试指定数据类型是否支持指定操作系统
function _TEST_DT_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_DT_OS (os) and m_dwState) <> 0);
end;

// 用作转换os类型以便加入到m_dwState
function _LIB_OS(os: LongWord): LongWord;
begin
  Result:= os;
end;

//用作测试支持库是否具有指定操作系统的版本
function _TEST_LIB_OS(m_dwState,os: LongWord): boolean;
begin
  Result:= ((_LIB_OS (os) and m_dwState) <> 0);
end;

//------------------------------------------------------------------------------


//从指定数据块中读取第index个整数，index取值从0开始。
function GetIntByIndex(pData : Pointer; index : Integer) : Integer;
begin
  result := PInteger(DWORD(pData) + DWORD(sizeof(Integer)*index))^;
end;

//修改指定数据块中第index个整数，index取值从0开始。
procedure SetIntByIndex(pData : Pointer; index : Integer; value : Integer);
begin
  PInteger(DWORD(pData) + DWORD(sizeof(Integer)*index))^ := value;
end;


////////////////////////////////////////////////////////////////////////////////
//
// 下面我们做了大量的工作, 用于简化易语言支持库开发
//
////////////////////////////////////////////////////////////////////////////////

// 以下 procedure/function 中, 没有在 interface 段声明的, 仅供内部使用


procedure FillLibInfo(out libInfo: LIB_INFO;
                      szName,szGuid,szExplain: PChar;
                      nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                      dwState: LongWord;
                      szAuthor,szHomePage,szOther: PChar;
                      nCategoryCount: Integer; szzCategory: PChar;
                      nCmdCount: Integer; pBeginCmdInfo: pCMD_INFO; pCmdsFunc: PPFN_EXECUTE_CMD;
                      nLibConstCount: Integer; pLibConst: pLIB_CONST_INFO;
                      nDataTypeCount: Integer; pDataType: pLIB_DATA_TYPE_INFO;
                      pfnRunAddInFn: PFN_RUN_ADDIN_FN; szzAddInFnInfo: PChar;
                      pfnNotify: PFN_NOTIFY_LIB;
                      szzDependFiles: PChar);
begin
  with libInfo do begin
    m_dwLibFormatVer := LIB_FORMAT_VER;
    m_szGuid := szGuid;
    m_nMajorVersion := nMajorVersion;
    m_nMinorVersion := nMinorVersion;
    m_nBuildNumber := nBuildNumber;
    m_nRqSysMajorVer := 4;
    m_nRqSysMinorVer := 0;
    m_nRqSysKrnlLibMajorVer := 4;
    m_nRqSysKrnlLibMinorVer := 5;
    m_szName := szName;
    m_nLanguage := nLanguage;
    m_szExplain := szExplain;
    m_dwState := dwState;

    m_szAuthor := szAuthor;
    m_szZipCode := nil;
    m_szAddress := nil;
    m_szPhoto := nil;
    m_szFax := nil;
    m_szEmail := nil;
    m_szHomePage := szHomePage;
    m_szOther := szOther;

    m_nDataTypeCount := nDataTypeCount;
    m_pDataType := pDataType;
    m_nCategoryCount := nCategoryCount;
    m_szzCategory := szzCategory;
    m_nCmdCount := nCmdCount;
    m_pBeginCmdInfo := pBeginCmdInfo;
    m_pCmdsFunc := pCmdsFunc;
    m_pfnRunAddInFn := pfnRunAddInFn;
    m_szzAddInFnInfo := szzAddInFnInfo;
    m_pfnNotify := pfnNotify;
    m_pfnSuperTemplate:=nil;
    m_szzSuperTemplateInfo:=nil;
    m_nLibConstCount := nLibConstCount;
    m_pLibConst := pLibConst;
    m_szzDependFiles:=nil;
  end;
end;

procedure FillCmdInfo(out cmdInfo: CMD_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel,shtCategory: SmallInt;
                      nArgCount: Integer; pBeginArgInfo: pARG_INFO;
                      shtBitmapIndex,shtBitmapCount: SmallInt);
begin
  with cmdInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtCategory := shtCategory;
    m_wState := wState;
    m_dtRetType := dtRetType;
    m_wReserved := 0;
    m_shtUserLevel := shtUserLevel;
    m_shtBitmapIndex := shtBitmapIndex;
    m_shtBitmapCount := shtBitmapCount;
    m_nArgCount := nArgCount;
    m_pBeginArgInfo := pBeginArgInfo;
  end;
end;

procedure FillArgInfo(out argInfo: ARG_INFO;
                      szName,szExplain: PChar;
                      dtDataType: DATA_TYPE;
                      dwState,nDefault: LongWord;
                      shtBitmapIndex,shtBitmapCount: SmallInt);
begin
  with argInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_shtBitmapIndex := shtBitmapIndex;
    m_shtBitmapCount := shtBitmapCount;
    m_dtDataType := dtDataType;
    m_nDefault := nDefault;
    m_dwState := dwState;
  end;
end;

procedure FillConstInfo(out constInfo: LIB_CONST_INFO;
                        szName,szEGName,szExplain: PChar;
                        shtType: SmallInt;
                        dbValue: Double; szTextValue: PChar);
begin
  with constInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtReserved := 1;
    m_shtType := shtType;
    m_szText := szTextValue;
    m_dbValue := dbValue;
  end;
end;

procedure FillDatatypeInfo(out datatypeInfo: LIB_DATA_TYPE_INFO;
                           szName,szEGName,szExplain: PChar;
                           dwState,dwUnitBmpID: LongWord;
                           nCmdCount: Integer; pnCmdsIndex: PInteger;
                           nEventCount: Integer; pEventBegin: pEVENT_INFO;
                           nPropertyCount: Integer; pPropertyBegin: pUNIT_PROPERTY;
                           nElementCount: Integer; pElementBegin: pLIB_DATA_TYPE_ELEMENT;
                           pfnGetInterface: PFN_GET_INTERFACE);
begin
  with datatypeInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_nCmdCount := nCmdCount;
    m_pnCmdsIndex := pnCmdsIndex;
    m_dwState := dwState;
    m_dwUnitBmpID := dwUnitBmpID;
    m_nEventCount := nEventCount;
    m_pEventBegin := pEventBegin;
    m_nPropertyCount := nPropertyCount;
    m_pPropertyBegin := pPropertyBegin;
    m_pfnGetInterface := pfnGetInterface;
    m_nElementCount := nElementCount;
    m_pElementBegin := pElementBegin;
  end;
end;

procedure FillEventInfo(out eventInfo: EVENT_INFO;
                        szName,szExplain: PChar;
                        dwState: LongWord;
                        nArgCount: Integer; pEventArgInfo: PEVENT_ARG_INFO);
begin
  with eventInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_nArgCount := nArgCount;
    m_pEventArgInfo := pEventArgInfo;
  end;
end;

procedure FillEventArgInfo(out eventArgInfo: EVENT_ARG_INFO;
                           szName,szExplain: PChar;
                           dwState: LongWord);
begin
  with eventArgInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
  end;
end;

procedure FillEventInfo2(out eventInfo: EVENT_INFO2;
                         szName,szExplain: PChar;
                         dwState: LongWord;
                         nArgCount: Integer; pEventArgInfo: PEVENT_ARG_INFO2;
                         dtRetDataType: DATA_TYPE);
begin
  with eventInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := (dwState or LongWord(EV_IS_VER2));
    m_nArgCount := nArgCount;
    m_pEventArgInfo := pEventArgInfo;
    m_dtRetDataType := dtRetDataType;
  end;
end;

procedure FillEventArgInfo2(out eventArgInfo: EVENT_ARG_INFO2;
                            szName,szExplain: PChar;
                            dwState: LongWord;
                            dtDataType: DATA_TYPE);
begin
  with eventArgInfo do begin
    m_szName := szName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_dtDataType := dtDataType;
  end;
end;

procedure FillPropertyInfo(out propertyInfo: UNIT_PROPERTY;
                           szName,szEGName,szExplain: PChar;
                           shtType: SmallInt; wState: Word;
                           szzPickStr: PChar);
begin
  with propertyInfo do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_shtType := shtType;
    m_wState := wState;
    m_szzPickStr := szzPickStr;
  end;
end;

procedure FillElementInfo(out elementInfo: LIB_DATA_TYPE_ELEMENT;
                          szName,szEGName,szExplain: PChar;
                          dtDataType: DATA_TYPE; pArySpec: PByte;
                          dwState: LongWord; nDefault: Integer);
begin
  with elementInfo do begin
    m_dtDataType := dtDataType;
    m_pArySpec := pArySpec;
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_dwState := dwState;
    m_nDefault := nDefault;
  end;
end;

//------------------------------------------------------------------------------

//if count > 0, returns the first element's memory address, or returns nil.
function GetMemAddressOfArray(const anArray; count: Integer) : Pointer;
begin
  if count > 0 then
    //'数组名称即其首成员地址', 已经过初步验证, 还需最后明确证实. 
    result := Pointer(anArray) //@(anArray[0])
  else
    result := nil;
end;

//only used by FixLibInfo()
procedure FixDatatypeInfo();
var 
  i, j: Integer;
  pCallOp: PDWORD;
begin

  with egdata do begin
  
    libInfo.m_nDataTypeCount := datatypeCount;
    libInfo.m_pDataType := GetMemAddressOfArray(datatypeInfos, datatypeCount);
    if datatypeCount = 0 then 
      exit; //no datatype

    for i := 0 to libInfo.m_nDataTypeCount - 1 do begin
      with datatypeInfos[i], datatypeDatas[i] do begin
        //methods
        m_nCmdCount := methodCount;
        m_pnCmdsIndex := GetMemAddressOfArray(methodIndexes, methodCount);

        //properties
        m_nPropertyCount := propertyCount;
        m_pPropertyBegin := GetMemAddressOfArray(propertyInfos, propertyCount);

        //elements
        m_nElementCount := elementCount;
        m_pElementBegin := GetMemAddressOfArray(elementInfos, elementCount);

        //events
        m_nEventCount := eventCount;
        if eventCount = 0 then begin
          m_pEventBegin := nil;
        end else begin
          m_pEventBegin := @(eventInfos[0]);
          //see DefineEventInfo()
          for j := 0 to eventCount - 1 do begin
            if eventInfos[j].m_nArgCount < 0 then begin
              eventInfos[j].m_nArgCount := 0 - eventInfos[j].m_nArgCount;
              eventInfos[j].m_pEventArgInfo := pEVENT_ARG_INFO2(@(eventArgInfos[Integer(eventInfos[j].m_pEventArgInfo)]));
            end;
          end;
        end;
        //end events

        //m_pfnGetInterface
        //fix the CALL instruction's param of the auto-generated-function , see ECreateDatetypeInterfaceGetterFunction()
        if interfaceGetterCodes[0] <> 0 then begin
          pCallOp := @interfaceGetterCodes[10];
          pCallOp^ := pCallOp^ - DWORD(@interfaceGetterCodes[14]);
          m_pfnGetInterface := @interfaceGetterCodes;
        end;
        
      end; //end of with datatypeInfos[i], datatypeDatas[i]
    end; //end of for

  end; //end of with
end;

//only used by DefineMethod() DefineMethod_NoArg() and FixUnbindingMethods()
procedure BindCommandToDatatype(datatypeIndex, cmdIndex: Integer);
begin
  with egdata.datatypeDatas[datatypeIndex] do begin
    Inc(methodCount);
    SetLength(methodIndexes, methodCount); //todo: buffered
    methodIndexes[methodCount - 1] := cmdIndex;
  end;
end;

procedure FixUnbindingMethods();
var
  i: Integer;
  indexOfMinVersionMethod: Integer;
  cmdIndexOfMethod: Integer;
  minVersion: DWORD;
begin
  with egdata do begin

    if unbindingMethodCount = 0 then exit;

    indexOfMinVersionMethod := 0;
    while indexOfMinVersionMethod <> -1 do begin

      //find the index of the unbinding Method that has the minimum version
      indexOfMinVersionMethod := -1;
      minVersion := 0;
      for i := 0 to unbindingMethodCount - 1 do begin
        if unbindingMethods[i].bound = true then continue;

        if minVersion = 0 then begin
          minVersion := unbindingMethods[i].version;
          indexOfMinVersionMethod := i;
          continue;
        end;
        if unbindingMethods[i].version < minVersion then begin
          minVersion := unbindingMethods[i].version;
          indexOfMinVersionMethod := i;
        end
      end;

      if indexOfMinVersionMethod <> -1 then begin
        with unbindingMethods[indexOfMinVersionMethod] do begin
          cmdIndexOfMethod := DefineCommand(cmdFunc, cmdArgs,
                                            cmdInfo.m_szName, cmdInfo.m_szEGName, cmdInfo.m_szExplain,
                                            cmdInfo.m_dtRetType, cmdInfo.m_wState,
                                            cmdInfo.m_shtUserLevel, cmdInfo.m_shtCategory,
                                            cmdInfo.m_shtBitmapIndex, cmdInfo.m_shtBitmapCount,
                                            0 {version} );
          if datatypeIndex <> -1 then
            BindCommandToDatatype(datatypeIndex, cmdIndexOfMethod);

          bound := true; //don't bind me next time
        end;
      end;
    end; //end of while

  end; //end of with egdtat
end;

//fix libinfo if necessary (only once)
//will invoke it in GetNewInf(), or anywhere before GetNewInf() returns.
//must be invoked after FillLibInfo()
procedure FixLibInfo();
var i: Integer;
begin

  with egdata do begin

      if hasFixedLibInfo then exit; //fix it only once
      hasFixedLibInfo := true;

      FixUnbindingMethods();

      //constCount, constInfos
      libInfo.m_nLibConstCount := constCount;
      libInfo.m_pLibConst := GetMemAddressOfArray(constInfos, constCount);
      
      //cmdCount, cmdInfos and cmdFuncs
      libInfo.m_nCmdCount := cmdCount;
      libInfo.m_pBeginCmdInfo := GetMemAddressOfArray(cmdInfos, cmdCount);
      libInfo.m_pCmdsFunc := GetMemAddressOfArray(cmdFuncs, cmdCount);

      //fix commands' argcount and arginfo, see DefineCommand()
      for i := 0 to cmdCount - 1 do begin
        if Integer(cmdInfos[i].m_nArgCount) < 0 then begin
          cmdInfos[i].m_nArgCount := 0 - Integer(cmdInfos[i].m_nArgCount);
          cmdInfos[i].m_pBeginArgInfo := @(argInfos[Integer(cmdInfos[i].m_pBeginArgInfo)]);
        end;
      end;

      //datatypeInfo
      FixDatatypeInfo();
      
  end; //end of with egdata do ...
  
end;

function GetLibInfo(): pLIB_INFO;
begin
  FixLibInfo(); //fix libinfo if necessary (only once)
  result := @(egdata.libInfo);
end;

procedure DefineLib(szName,szGuid,szExplain: PChar;
                    nMajorVersion,nMinorVersion,nBuildNumber,nLanguage: Integer;
                    dwState: LongWord;
                    szAuthor,szHomePage,szOther: PChar;
                    nCategoryCount: Integer; szzCategory: PChar;
                    pfnRunAddInFn: PFN_RUN_ADDIN_FN = nil; szzAddInFnInfo: PChar = nil;
                    pfnNotifyLib: PFN_NOTIFY_LIB = nil; //default to DefaultProcessNotifyLib
                    szzDependFiles: PChar = nil;
                    pfnFreeLibData: PFN_FREE_LIB_DATA = nil);
begin

  if not Assigned(pfnNotifyLib) then 
    pfnNotifyLib := @DefaultProcessNotifyLib;

  egdata.fnFreeLibData := pfnFreeLibData;

  FillLibInfo(egdata.libInfo,
              szName, szGuid, szExplain,
              nMajorVersion, nMinorVersion, nBuildNumber, nLanguage,
              dwState or _LIB_OS(__OS_WIN),
              szAuthor, szHomePage, szOther,
              nCategoryCount, szzCategory,
              0, nil, nil, //nCmdCount, pBeginCmdInfo, pCmdsFunc
              0, nil, //nLibConstCount, pLibConst
              0, nil, //nDataTypeCount, pDataType
              pfnRunAddInFn, szzAddInFnInfo,
              pfnNotifyLib, szzDependFiles,
             );

  //这里暂不填充 pBeginCmdInfo,pCmdsFunc,pLibConst,pDataType，如此就不必限制DefineLib()与DefineMethod()等的调用顺序。
  //FixLibInfo()将做剩余的工作

end;

procedure DefineConst(szName,szEGName,szExplain: PChar;
                      shtType: SmallInt;
                      dbValue: Double = 0.0; szTextValue: PChar = nil);
begin
  Inc(egdata.constCount);
  SetLength(egdata.constInfos, egdata.constCount); //todo: buffered
  FillConstInfo(egdata.constInfos[egdata.constCount-1],
                szName, szEGName, szExplain, shtType, dbValue, szTextValue);
end;

procedure DefineIntConst(szName,szEGName,szExplain: PChar; value: Integer);
begin
  DefineConst(szName, szEGName, szExplain, CT_NUM, value);
end;

procedure DefineDoubleConst(szName,szEGName,szExplain: PChar; value: Double);
begin
  DefineConst(szName, szEGName, szExplain, CT_NUM, value);
end;

procedure DefineBoolConst(szName,szEGName,szExplain: PChar; value: EBool);
var v: Double;
begin
  if value = ETrue then v := 1 else v := 0;
  DefineConst(szName, szEGName, szExplain, CT_BOOL, v);
end;

procedure DefineTextConst(szName,szEGName,szExplain: PChar; value: PChar);
begin
  DefineConst(szName, szEGName, szExplain, CT_TEXT, 0.0, value);
end;

{procedure DefineHiddenConst(nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineConst('', '', '', CT_NULL); //CT_NULL含义是未知的, 并不代表隐藏
  end;
end;}

//only used by DefineCommand_NoArg()
function IsValidCommandUserLevel(shtUserLevel: SmallInt) : bool;
begin
  result := ((shtUserLevel = LVL_SIMPLE) or (shtUserLevel = LVL_SECONDARY) or (shtUserLevel = LVL_HIGH))
end;

procedure DelayDefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0);
var i: Integer;
begin
  with egdata do begin
    Inc(unbindingMethodCount);
    SetLength(unbindingMethods, unbindingMethodCount);

    unbindingMethods[unbindingMethodCount - 1].version := version;
    unbindingMethods[unbindingMethodCount - 1].datatypeIndex := -1; //is command, not method

    FillCmdInfo(unbindingMethods[unbindingMethodCount - 1].cmdInfo,
                szName, szEGName, szExplain,
                dtRetType, wState or _CMD_OS(__OS_WIN),
                shtUserLevel, shtCategory,
                0, nil, {nArgCount, pBeginArgInfo}
                shtBitmapIndex, shtBitmapCount);

    unbindingMethods[unbindingMethodCount - 1].cmdFunc := cmdFunc;

    SetLength(unbindingMethods[unbindingMethodCount - 1].cmdArgs, Length(args));
    for i := 0 to High(args) do begin
      unbindingMethods[unbindingMethodCount - 1].cmdArgs[i] := args[i];
    end;

  end; //end of with egdata
end;

function DefineCommand(cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                       szName,szEGName,szExplain: PChar;
                       dtRetType: DATA_TYPE; wState: Word;
                       shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                       shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                       version: DWORD = 0) : Integer;
var
  i, baseIndex: integer;
begin

  if version = 0 then begin

    //return the command's index
    result :=  DefineCommand_NoArg(cmdFunc,
                                   szName, szEGName, szExplain,
                                   dtRetType, wState,
                                   shtUserLevel, shtCategory,
                                   shtBitmapIndex, shtBitmapCount);

    if length(args) = 0 then exit;

    //store args to global data.
    //注: 即使args是一个常量(const)静态数组, 也可能会被提前释放! --根据结果进行的猜测, 待验证.
    //所以将参数数组信息复制一份保存下来是必要的.

    Inc(egdata.argCount, Length(args));
    SetLength(egdata.argInfos, egdata.argCount);
    baseIndex := egdata.argCount - Length(args);
    for i := 0 to High(args) do begin
      egdata.argInfos[baseIndex + i] := args[i];
    end;

    //参数个数填写负值(作为标记), 参数信息首地址填写其在egdata.argInfos中的成员索引. FixLibInfo()中将修正之.
    //(因为egdata.argInfos增肥之后, 内存地址很可能发生变化, 现在就取其某个成员的内存地址是不明智的)
    egdata.cmdInfos[egdata.cmdCount-1].m_nArgCount := 0 - Length(args);
    egdata.cmdInfos[egdata.cmdCount-1].m_pBeginArgInfo := pARG_INFO(baseIndex);

  end else begin

    DelayDefineCommand(cmdFunc, args,
                       szName, szEGName, szExplain,
                       dtRetType, wState, shtUserLevel, shtCategory,
                       shtBitmapIndex, shtBitmapCount,
                       version);
    result := -1;

  end;
end;

function DefineCommand_NoArg(cmdFunc: PFN_EXECUTE_CMD;
                             szName,szEGName,szExplain: PChar;
                             dtRetType: DATA_TYPE; wState: Word;
                             shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = 0;
                             shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                             version: DWORD = 0) : Integer;
begin

  if version = 0 then begin

    Inc(egdata.cmdCount);
    SetLength(egdata.cmdInfos, egdata.cmdCount); //todo: buffered
    SetLength(egdata.cmdFuncs, egdata.cmdCount); //todo: buffered

    if not IsValidCommandUserLevel(shtUserLevel) then
      shtUserLevel := LVL_SIMPLE;

    FillCmdInfo(egdata.cmdInfos[egdata.cmdCount-1],
                szName, szEGName, szExplain,
                dtRetType, wState or _CMD_OS(__OS_WIN),
                shtUserLevel, shtCategory,
                0, nil, //nArgCount, pBeginArgInfo
                shtBitmapIndex, shtBitmapCount);

    egdata.cmdFuncs[egdata.cmdCount-1] := cmdFunc;

    result := egdata.cmdCount - 1;

  end else begin

    DelayDefineCommand(cmdFunc, [],
                       szName, szEGName, szExplain,
                       dtRetType, wState, shtUserLevel, shtCategory,
                       shtBitmapIndex, shtBitmapCount,
                       version);
    result := -1;

  end;
end;

procedure DefineHiddenCommand(nRepeatCount: Integer = 1; version: DWORD = 0);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineCommand_NoArg(nil, '', '', '', _SDT_NULL, CT_IS_HIDED, LVL_SIMPLE,
                        0, 0, 0, version);
  end;
end;

//return the new datatype's index
function DefineDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;
begin
  Inc(egdata.datatypeCount);
  SetLength(egdata.datatypeInfos, egdata.datatypeCount); //todo: buffered
  SetLength(egdata.datatypeDatas, egdata.datatypeCount); //todo: buffered

  with egdata.datatypeInfos[egdata.datatypeCount - 1] do begin
    m_szName := szName;
    m_szEGName := szEGName;
    m_szExplain := szExplain;
    m_dwState := dwState or _DT_OS(__OS_WIN);
  end;

  //other infos, such as methods/properties/events/elements,
  //will be filled in FixLibInfo(), or really in FixDatatypeInfo(), invoked by the former.

  result := egdata.datatypeCount - 1;
end;

procedure DefineHiddenDatatype(nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineDatatype('', '', '', LDT_IS_HIDED);
  end;
end;

//return the new datatype's index
function DefineEnumDatatype(szName,szEGName,szExplain: PChar; dwState: LongWord = 0) : Integer;
begin
  result := DefineDatatype(szName, szEGName, szExplain, (dwState or LDT_ENUM));
end;

////////////////////////////////////////////////////////////////////////////////

//only used by DefineUIDatatype()
procedure DefineFixedProperties(datatypeIndex: Integer {datatypeIndex must exist});
begin
  DefineProperty(datatypeIndex, '左边', 'left', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '顶边', 'top', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '宽度', 'width', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '高度', 'height', nil, UD_INT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '标记', 'tag', nil, UD_TEXT, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '可视', 'visible', nil, UD_BOOL, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '禁止', 'disable', nil, UD_BOOL, _PROP_OS(OS_ALL), nil);
  DefineProperty(datatypeIndex, '鼠标指针', 'MousePointer', nil, UD_CURSOR, _PROP_OS(OS_ALL), nil);
end;

//only used by EInterfaceGetterTempletCodes
function GetInterfaceOfDatatype(nDatatypeIndex, nInterfaceNO: Integer): PFN_INTERFACE;
begin
  result := nil;
  if (nInterfaceNO < ITF_CREATE_UNIT) or (nInterfaceNO > ITF_GET_NOTIFY_RECEIVER) then
    exit;
  result := PFN_INTERFACE( egdata.datatypeDatas[nDatatypeIndex].interfaces[nInterfaceNO] );
end;

{
function EInterfaceGetterTempletCodes(nInterfaceNO: Integer): PFN_INTERFACE; stdcall;
begin
  result := GetInterfaceOfDatatype(<datatypeIndex>, nInterfaceNO);
end;
}
const EInterfaceGetterTempletCodes: array[0..16] of Byte = (
    $8B, $54, $24, $04,      //mov edx, [esp+$04]
    $B8, $00, $00, $00, $00, //mov eax, <datatypeIndex>
    $E8, $00, $00, $00, $00, //call <GetInterfaceOfDatatype>
    $C2, $04, $00            //ret $0004;
  );

//copy from EInterfaceGetterTempletCodes, and fill in <datatypeIndex> and <GetInterfaceOfDatatype>
//the size of codesBuffer must be enought to fill in EInterfaceGetterTempletCodes
procedure ECreateDatetypeInterfaceGetterFunction(var codesBuffer: array of Byte; datatypeIndex: Integer);
var
  pDatatypeIndex: PInteger;
  pGetInterfaceOfDatatype: PDWORD;
begin
  CopyMemory(@codesBuffer[0], @EInterfaceGetterTempletCodes, Length(EInterfaceGetterTempletCodes));
  pDatatypeIndex := PInteger(@(codesBuffer[5]));
  pDatatypeIndex^ := Integer(datatypeIndex); //<datatypeIndex>
  pGetInterfaceOfDatatype := PDWORD(@(codesBuffer[10]));
  pGetInterfaceOfDatatype^ := DWORD(@GetInterfaceOfDatatype); //<GetInterfaceOfDatatype>
end;

////////////////////////////////////////////////////////////////////////////////

//return the new datatype's index
function DefineUIDatatype(szName,szEGName,szExplain: PChar;
                          dwState,dwUnitBmpID: LongWord;
                          pfnGetInterface: PFN_GET_INTERFACE = nil;
                          onCreateUnit: PFN_CREATE_UNIT = nil;
                          onGetPropertyValue: PFN_GET_PROPERTY_DATA = nil;
                          onSetPropertyValue: PFN_NOTIFY_PROPERTY_CHANGED = nil;
                          onGetAllPropertiesValue: PFN_GET_ALL_PROPERTY_DATA = nil;
                          onPropertyUpdateUI: PFN_PROPERTY_UPDATE_UI = nil;
                          onInitDlgCustomData: PFN_DLG_INIT_CUSTOMIZE_DATA = nil;
                          onGetIconPropertyValue: PFN_GET_ICON_PROPERTY_DATA = nil;
                          onIsNeedThisKey: PFN_IS_NEED_THIS_KEY = nil;
                          onLanguageConv: PFN_LANG_CNV = nil;
                          onMsgFilter: PFN_MESSAGE_FILTER = nil;
                          onNotifyUnit: PFN_ON_NOTIFY_UNIT = nil ) : Integer;
var
  datatypeIndex: Integer;
begin

  datatypeIndex := DefineDatatype(szName, szEGName, szExplain, (dwState or LDT_WIN_UNIT));
  result := datatypeIndex;

  with egdata.datatypeInfos[datatypeIndex] do begin
    m_dwUnitBmpID := dwUnitBmpID;
    m_pfnGetInterface := pfnGetInterface;
  end;

  DefineFixedProperties(datatypeIndex);

  if Assigned(pfnGetInterface) then exit;

  //以下, 为 LIB_DATA_TYPE_INFO.m_pfnGetInterface 自动生成相应函数, 详见: ECreateDatetypeInterfaceGetterFunction()
  //将在 FixLibData() 中修正生成的代码, 并填充 LIB_DATA_TYPE_INFO.m_pfnGetInterface
  ECreateDatetypeInterfaceGetterFunction(egdata.datatypeDatas[datatypeIndex].interfaceGetterCodes, datatypeIndex);

  with egdata.datatypeDatas[datatypeIndex] do begin
    interfaces[{1} ITF_CREATE_UNIT] := PFN_INTERFACE(onCreateUnit);
    interfaces[{2} ITF_PROPERTY_UPDATE_UI] := PFN_INTERFACE(onPropertyUpdateUI);
    interfaces[{3} ITF_DLG_INIT_CUSTOMIZE_DATA] := PFN_INTERFACE(onInitDlgCustomData);
    interfaces[{4} ITF_NOTIFY_PROPERTY_CHANGED] := PFN_INTERFACE(onSetPropertyValue);
    interfaces[{5} ITF_GET_ALL_PROPERTY_DATA] := PFN_INTERFACE(onGetAllPropertiesValue);
    interfaces[{6} ITF_GET_PROPERTY_DATA] := PFN_INTERFACE(onGetPropertyValue);
    interfaces[{7} ITF_GET_ICON_PROPERTY_DATA] := PFN_INTERFACE(onGetIconPropertyValue);
    interfaces[{8} ITF_IS_NEED_THIS_KEY] := PFN_INTERFACE(onIsNeedThisKey);
    interfaces[{9} ITF_LANG_CNV] := PFN_INTERFACE(onLanguageConv);
    interfaces[10] := nil;
    interfaces[{11} ITF_MSG_FILTER] := PFN_INTERFACE(onMsgFilter);
    interfaces[{12} ITF_GET_NOTIFY_RECEIVER] := PFN_INTERFACE(onNotifyUnit);
  end;

end;

procedure DelayDefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0);
begin

  DelayDefineCommand(cmdFunc, args,
                     szName, szEGName, szExplain,
                     dtRetType, wState,
                     shtUserLevel, -1{shtCategory},
                     shtBitmapIndex, shtBitmapCount,
                     version);

  with egdata do begin
    unbindingMethods[unbindingMethodCount - 1].datatypeIndex := datatypeIndex;
  end;

end;

function DefineMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                      cmdFunc: PFN_EXECUTE_CMD; args: array of ARG_INFO;
                      szName,szEGName,szExplain: PChar;
                      dtRetType: DATA_TYPE; wState: Word;
                      shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                      shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                      version: DWORD = 0) : Integer;
var cmdIndex: Integer;
begin

  if version = 0 then begin
    cmdIndex :=  DefineCommand(cmdFunc, args,
                               szName, szEGName, szExplain,
                               dtRetType, wState,
                               shtUserLevel, -1{shtCategory},
                               shtBitmapIndex, shtBitmapCount);

    BindCommandToDatatype(datatypeIndex, cmdIndex);

    result := cmdIndex; //return the method's index (of all commands in the library)

  end else begin

    DelayDefineMethod(datatypeIndex, cmdFunc, args,
                      szName, szEGName, szExplain,
                      dtRetType, wState, shtUserLevel, -1{shtCategory},
                      shtBitmapIndex, shtBitmapCount,
                      version);
    result := -1;

  end;
end;

function DefineMethod_NoArg(datatypeIndex: Integer; {datatypeIndex must exist}
                            cmdFunc: PFN_EXECUTE_CMD;
                            szName,szEGName,szExplain: PChar;
                            dtRetType: DATA_TYPE; wState: Word;
                            shtUserLevel: SmallInt = LVL_SIMPLE; shtCategory: SmallInt = -1;
                            shtBitmapIndex: SmallInt = 0; shtBitmapCount: SmallInt = 0;
                            version: DWORD = 0) : Integer;
var cmdIndex: Integer;
begin
  if version = 0 then begin

    cmdIndex :=  DefineCommand_NoArg(cmdFunc,
                                     szName, szEGName, szExplain,
                                     dtRetType, wState,
                                     shtUserLevel, -1{shtCategory},
                                     shtBitmapIndex, shtBitmapCount);

    BindCommandToDatatype(datatypeIndex, cmdIndex);

    result := cmdIndex; //return the method's index (of all commands)

  end else begin

    DelayDefineMethod(datatypeIndex, cmdFunc, [],
                      szName, szEGName, szExplain,
                      dtRetType, wState, shtUserLevel, -1{shtCategory},
                      shtBitmapIndex, shtBitmapCount,
                      version);
    result := -1;

  end;
end;

procedure DefineHiddenMethod(datatypeIndex: Integer; {datatypeIndex must exist}
                             nRepeatCount: Integer = 1; version: DWORD = 0);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineMethod_NoArg(datatypeIndex, nil, '', '', '', _SDT_NULL, CT_IS_HIDED,
                       LVL_SIMPLE, -1, 0, 0, version);
  end;
end;

procedure DefineElement(datatypeIndex: Integer; {datatypeIndex must exist}
                        szName,szEGName,szExplain: PChar;
                        dtDataType: DATA_TYPE; pArySpec: PByte = nil;
                        dwState: LongWord = 0; nDefault: Integer = 0);
begin

  with egdata.datatypeDatas[datatypeIndex] do begin
    Inc(elementCount);
    SetLength(elementInfos, elementCount);
    FillElementInfo(elementInfos[elementCount - 1],
                    szName, szEGName, szExplain,
                    dtDataType, pArySpec,
                    dwState, nDefault);
  end;
end;

procedure DefineHiddenElement(datatypeIndex: Integer; {datatypeIndex must exist}
                              nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineElement(datatypeIndex, '', '', '', SDT_INT, nil, LES_HIDED, 0);
  end;
end;

procedure DefineEnumElement(datatypeIndex: Integer; {datatypeIndex must exist}
                            szName,szEGName,szExplain: PChar;
                            nValue: Integer; dwState: LongWord = 0);
begin
  DefineElement(datatypeIndex,
                szName, szEGName, szExplain,
                SDT_INT, nil, {must be SDT_INT and nil in Enum datatype}
                dwState, nValue);
end;

procedure DefineEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                      szName,szExplain: PChar; dwState: LongWord;
                      args: array of EVENT_ARG_INFO2;
                      dtRetDataType: DATA_TYPE);
var
  nArgCount, i, baseIndex: Integer;
begin

  nArgCount := Length(args);

  with egdata, datatypeDatas[datatypeIndex] do begin

    Inc(eventCount);
    SetLength(eventInfos, eventCount); //todo: buffered

    if nArgCount > 0 then begin
      //store args to global data, see DefineCommand()
      baseIndex := eventArgCount;
      Inc(eventArgCount, nArgCount);
      SetLength(eventArgInfos, eventArgCount); //todo: buffered
      for i := 0 to nArgCount - 1 do begin
        eventArgInfos[baseIndex + i] := args[i];
      end;
    end else begin
      baseIndex := 0; //nil
    end;

    FillEventInfo2(eventInfos[eventCount - 1],
                   szName, szExplain, (dwState or _EVENT_OS(__OS_WIN)),
                   0 - nArgCount, pEVENT_ARG_INFO2(baseIndex), //参数个数填入负值, 参数信息地址填入索引. see DefineCommand(). FixLibInfo() will fix this.
                   dtRetDataType);
  end;
end;

procedure DefineHiddenEvent(datatypeIndex: Integer; {datatypeIndex must exist}
                            nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineEvent(datatypeIndex, '', '', EV_IS_HIDED, [], _SDT_NULL);
  end;
end;

procedure DefineProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                         szName,szEGName,szExplain: PChar;
                         shtType: SmallInt; wState: Word;
                         szzPickStr: PChar);
begin
  with egdata, datatypeDatas[datatypeIndex] do begin

    Inc(propertyCount);
    SetLength(propertyInfos, propertyCount); //todo: buffered

    FillPropertyInfo(propertyInfos[propertyCount - 1],
                     szName, szEGName, szExplain,
                     shtType, (wState or _PROP_OS(__OS_WIN)),
                     szzPickStr);

  end; //end of with
end;

procedure DefineHiddenProperty(datatypeIndex: Integer; {datatypeIndex must exist}
                               nRepeatCount: Integer = 1);
var i: Integer;
begin
  for i := 1 to nRepeatCount do begin
    DefineProperty(datatypeIndex, '', '', '', UD_INT, UW_IS_HIDED, nil);
  end;
end;

////////////////////////////////////////////////////////////////////////////////
//
// 结束语:
//
//     Good Luck!
//
////////////////////////////////////////////////////////////////////////////////

end.


