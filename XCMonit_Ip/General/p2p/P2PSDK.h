
#ifdef __cplusplus
extern "C" {
#endif

#ifndef __P2PSDK_H__
#define __P2PSDK_H__



//#include <string>
#include <stdio.h>
#define MAX_MSG_DATA_LEN 2048
#define  MAX_VERSION_LENGTH   32

#ifdef _MSC_VER_
#pragma pack(push, 1)
#define PP_PACKED
#elif defined(__GNUC__)
#define PP_PACKED __attribute__ ((packed))
#else
#define PP_PACKED
#endif

typedef struct 
{    
    short           resultCode;  //     ���ؽ������
    
}PP_PACKED NetMsgResHeader;

// ʵʱ��Ƶ֡��¼��ط���Ƶ֡ǰ��֡ͷ
typedef struct 
{
    unsigned int  timeStamp ; // ʱ������ӻطŵĿ�ʼʱ�侭���ĺ�����
    unsigned int  videoLen;   // ��Ƶ֡���� (������֡ͷ)
    unsigned char bIframe;    // �Ƿ��ǹؼ�֡��0�� �ǹؼ�֡ 1:�ؼ�֡
    unsigned char reserved[7]; // ����
}PP_PACKED P2P_FrameHeader;

//***************************** ʵʱ�������Ϣ ********************************
// ��ʵʱ����Ϣ
typedef struct PlayRealStreamMsg
{
    short streamType;  // 1:������ 2:������
    short channelNo;  // ͨ����
}PlayRealStreamMsg;

// ֹͣʵʱ����Ϣ
typedef struct StopRealStreamMsg
{
    short streamType;  // 1:������ 2:������
    short channelNo;  // ͨ����
}StopRealStreamMsg;

// ʵʱ������Ӧ��
typedef struct 
{
    NetMsgResHeader header;
    // ������Ҫ��չ��������
}PP_PACKED PlayRealStreamMsgRes;

// �ر�ʵʱ������Ӧ��
typedef struct 
{
    NetMsgResHeader header;
    // ������Ҫ��չ��������
}PP_PACKED StopRealStreamMsgRes;


//***************************** ¼��ط������Ϣ ****************************
#if 0
// ¼��ط���Ϣ
typedef struct _playrecordmsg
{
	unsigned short        channelNo;                 // ͨ����
	unsigned short        frameType;		// ֡����(0:��Ƶ,1:��Ƶ,2:����Ƶ) 
	unsigned int            startTime;	                // ��ʼʱ��
	unsigned int            endTime;		        // ����ʱ��
	unsigned int            nalarmFileType;        // 1:��ͨ¼���ļ�   2:����¼���ļ� 
}PP_PACKED PlayRecordMsg;

typedef struct  _NvrRecordinfo
{
	unsigned short diskNo;//Ӳ�̺�
	unsigned short recordNo;// ¼���ļ���%04X����Ϊ¼���ļ�����
	unsigned short fileType;//�ļ�����  bit0����ʱ¼�� bit1���澯¼�� bit2���ֶ�¼��
	unsigned char unused[2];//
	unsigned int startTime;//¼����ʼʱ�䣨�룩
	unsigned int endTime;//¼�����ʱ�䣨�룩
	unsigned int startAddr;//���ļ���һ֡��Ӧ��¼���ļ���I֡�����ĵ�ַ
	unsigned int endAddr;//���ļ����һ֡��Ӧ��¼���ļ���I֡�����ĵ�ַ
	unsigned int dataStartAddr;//¼���ļ���ʼ��ַ
	unsigned int dataEndAddr;//¼�������ļ�������ַ
}PP_PACKED RecordFileMsg;
typedef struct  _NvrRecordfile
{
	unsigned int  count;  //¼���ļ��ܸ���
	struct  _NvrRecordinfo*  RecordInfo;
}PP_PACKED RecordFileMsg;
typedef enum {
	DVR		      		      = 0,	//DVR�豸
	NVR			              = 1,	//NVR�豸
}DeviceType;
typedef struct  _playrecordresp
{
	DeviceType    devicetype;  //�豸����(�����豸���͵�ԭ������ΪNVR��DVR��¼�� �ļ���Ϣ�ṹ�岻һ�������Ҳ���ͳһ)
	char              recordmsg[MAX_MSG_DATA_LEN];//¼���ļ���Ϣ(DVR¼���ļ���Ϣ��NVR¼���ļ���Ϣ�ṹ�岻һ��)
}PP_PACKED PlayRecordResMsg;
#endif
// ¼��ط�Ӧ����Ϣ
typedef struct _playrecordmsg
{
	unsigned short        channelNo;                 // ͨ����
	unsigned short        frameType;		// ֡����(0:��Ƶ,1:��Ƶ,2:����Ƶ) 
	unsigned int            startTime;	                // ��ʼʱ��
	unsigned int            endTime;		        // ����ʱ��
	unsigned int            nalarmFileType;        // 1:��ͨ¼���ļ�   2:����¼���ļ�
	char                       reserve[8];                //����
}PP_PACKED PlayRecordMsg;
typedef struct  _playrecordresp
{
	unsigned int  count;  //¼���ļ��ܸ���
	struct  _playrecordmsg*  RecordInfo;
}PP_PACKED PlayRecordResMsg;

typedef enum {
	PB_PLAY		        		= 0,	//����
	PB_PAUSE			    	= 1,	//��ͣ
	PB_STEPFORWARD		      = 2,	//��֡��
	PB_STEPBACKWARD		      = 3,	//��֡��
	PB_FORWARD			      = 4,	//���
	PB_BACKWARD			      = 5,	//����
}PlayBackControl;

// ¼��طſ�����Ϣ
typedef struct 
{
    unsigned short        channelNo;                 // ͨ����
    unsigned short        frameType;		// ֡����(0:��Ƶ,1:��Ƶ,2:����Ƶ) 	
    PlayBackControl ctrl;
}PP_PACKED PlayRecordCtrlMsg;

// ¼��طſ���Ӧ����Ϣ
typedef struct 
{
    NetMsgResHeader header;
}PP_PACKED PlayRecordCtrlResMsg;
typedef enum {
	PTZCONTROLTYPE_INVALID		= 0,
	PTZCONTROLTYPE_UP_START 	= 1,    //��ʼ����ת��
	PTZCONTROLTYPE_UP_STOP		= 2,
	PTZCONTROLTYPE_DOWN_START		= 3,
	PTZCONTROLTYPE_DOWN_STOP		= 4,
	PTZCONTROLTYPE_LEFT_START		= 5, 
	PTZCONTROLTYPE_LEFT_STOP		= 6,
	PTZCONTROLTYPE_RIGHT_START		= 7,
	PTZCONTROLTYPE_RIGHT_STOP		= 8,
	PTZCONTROLTYPE_UPLEFT_START 	= 9,     //��ʼ������ת��
	PTZCONTROLTYPE_UPLEFT_STOP		= 10,  
	PTZCONTROLTYPE_UPRIGHT_START		= 11,
	PTZCONTROLTYPE_UPRIGHT_STOP 	= 12,
	PTZCONTROLTYPE_DOWNLEFT_START		= 13,
	PTZCONTROLTYPE_DOWNLEFT_STOP		= 14,
	PTZCONTROLTYPE_DOWNRIGHT_START	= 15,
	PTZCONTROLTYPE_DOWNRIGHT_STOP	= 16,
	PTZCONTROLTYPE_ZOOMWIDE_START		= 17,    //�Ŵ�
	PTZCONTROLTYPE_ZOOMWIDE_STOP		= 18,
	PTZCONTROLTYPE_ZOOMTELE_START		= 19,   //��С
	PTZCONTROLTYPE_ZOOMTELE_STOP		= 20,
	PTZCONTROLTYPE_FOCUSNEAR_START	= 21,           //�۽�����
	PTZCONTROLTYPE_FOCUSNEAR_STOP	= 22,
	PTZCONTROLTYPE_FOCUSFAR_START	= 23,           //�۽���Զ
	PTZCONTROLTYPE_FOCUSFAR_STOP	= 24,
} PTZCONTROLTYPE;
typedef struct  _PtzControlMsg
{
	PTZCONTROLTYPE   ptzcmd;
	int                           channel;  // ��Ӧͨ����(��0��ʼ) 
}PP_PACKED PtzControlMsg;
typedef struct _DeviceStreamMsg
{
    short streamType;  // 1:������ 2:������
    short channelNo;  // ͨ����
}DeviceStreamMsgReq;
//************************************************************************
typedef struct 
{
    int       streamsend_statue;     //�����ķ���״̬    0:failed    1:�ɹ�
    int       framerate;  //֡��
    int       streambitrate;   //������С
    char     deviceversion[MAX_VERSION_LENGTH];  //�豸�汾��Ϣ
}PP_PACKED DeviceStreamInfoResp;

// ��Ϣ����
typedef enum
{
    UNKOWN_MSG =0, 
    PLAY_REAL_STREAM = 1 ,
    PLAY_REAL_STREAM_RES =2 ,
    STOP_REAL_STREAM = 3 ,
    STOP_REAL_STREAM_RES =4  ,
    PLAY_RECORD_STREAM = 5,   // ����ط�¼������Ϣ����
    PLAY_RECORD_STREAM_RES = 6,
    PLAY_RECORD_CTRL = 7 ,    // ¼��طſ������������ͣ��������˵ȡ�
    PLAY_RECORD_CTRL_RES = 8,
    RELAY_STREAM_DATA = 9,
    START_PTZ_CTRL = 10,
    START_PTZ_CTRL_RES = 11,
    SYSTEM_REBOOT = 12,
    GET_DEVICE_STREAMINFO = 13,
    GET_DEVICE_STREAMINFO_RES = 14,
    GET_DEVICE_RECORDINFO = 15,
    GET_DEVICE_RECORDINFO_RES = 16,
    STOP_RECORD_STREAM = 17,   // ֹͣ�ط�¼������Ϣ����
    STOP_RECORD_STREAM_RES = 18,
}MsgType;
// ������Ϣ
typedef struct _NetMsg
{
	unsigned short  msgType;
    unsigned short  msgDataLen;
	unsigned char   msgData[MAX_MSG_DATA_LEN]; 
	/*_NetMsg()
	{
		msgType = 0;
        msgDataLen = 0;
		for(int i = 0;i < MAX_MSG_DATA_LEN;i++)
		{
			msgData[i] = '\0';
		}
	}*/
}PP_PACKED NetMsg;

// ��ϢӦ��
typedef struct _NetMsgRes
{
    unsigned short  msgType; // ��Ϣ����
    unsigned short  msgDataLen;                  // Ӧ�ò���Ϣ�峤��
	unsigned char   msgData[MAX_MSG_DATA_LEN];   //  Ӧ�ò���Ϣ������
}PP_PACKED NetMsgRes;

#ifdef _MSC_VER_
#pragma pack(pop)
#endif

#endif
#ifdef __cplusplus
}
#endif
