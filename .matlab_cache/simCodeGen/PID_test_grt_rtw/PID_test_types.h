/*
 * PID_test_types.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "PID_test".
 *
 * Model version              : 1.10
 * Simulink Coder version : 9.5 (R2021a) 14-Nov-2020
 * C++ source code generated on : Tue Jun 15 16:58:35 2021
 *
 * Target selection: grt.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Windows64)
 * Code generation objective: Execution efficiency
 * Validation result: Not run
 */

#ifndef RTW_HEADER_PID_test_types_h_
#define RTW_HEADER_PID_test_types_h_
#include "rtwtypes.h"
#include "multiword_types.h"

/* Model Code Variants */
#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_ros_time_Time_
#define DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_ros_time_Time_

struct SL_Bus_PID_test_ros_time_Time
{
  real_T Sec;
  real_T Nsec;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_
#define DEFINED_TYPEDEF_FOR_SL_Bus_ROSVariableLengthArrayInfo_

struct SL_Bus_ROSVariableLengthArrayInfo
{
  uint32_T CurrentLength;
  uint32_T ReceivedLength;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_std_msgs_Header_
#define DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_std_msgs_Header_

struct SL_Bus_PID_test_std_msgs_Header
{
  uint32_T Seq;
  SL_Bus_PID_test_ros_time_Time Stamp;
  uint8_T FrameId[128];
  SL_Bus_ROSVariableLengthArrayInfo FrameId_SL_Info;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_geometry_msgs_Point_
#define DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_geometry_msgs_Point_

struct SL_Bus_PID_test_geometry_msgs_Point
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_geometry_msgs_Vector3_
#define DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_geometry_msgs_Vector3_

struct SL_Bus_PID_test_geometry_msgs_Vector3
{
  real_T X;
  real_T Y;
  real_T Z;
};

#endif

#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_mavros_msgs_PositionTarget_
#define DEFINED_TYPEDEF_FOR_SL_Bus_PID_test_mavros_msgs_PositionTarget_

struct SL_Bus_PID_test_mavros_msgs_PositionTarget
{
  SL_Bus_PID_test_std_msgs_Header Header;
  uint8_T CoordinateFrame;
  uint16_T TypeMask;
  SL_Bus_PID_test_geometry_msgs_Point Position;
  SL_Bus_PID_test_geometry_msgs_Vector3 Velocity;
  SL_Bus_PID_test_geometry_msgs_Vector3 AccelerationOrForce;
  real32_T Yaw;
  real32_T YawRate;
};

#endif

#ifndef struct_ros_slroscpp_internal_block_P_T
#define struct_ros_slroscpp_internal_block_P_T

struct ros_slroscpp_internal_block_P_T
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
};

#endif                              /* struct_ros_slroscpp_internal_block_P_T */

/* Forward declaration for rtModel */
typedef struct tag_RTM_PID_test_T RT_MODEL_PID_test_T;

#endif                                 /* RTW_HEADER_PID_test_types_h_ */
