/*
 * robotROSGetStartedExample_edit_types.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "robotROSGetStartedExample_edit".
 *
 * Model version              : 6.3
 * Simulink Coder version : 9.5 (R2021a) 14-Nov-2020
 * C++ source code generated on : Wed Jun 16 16:08:32 2021
 *
 * Target selection: ert.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: Intel->x86-64 (Linux 64)
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef RTW_HEADER_robotROSGetStartedExample_edit_types_h_
#define RTW_HEADER_robotROSGetStartedExample_edit_types_h_
#include "rtwtypes.h"
#include "multiword_types.h"

/* Model Code Variants */
#ifndef DEFINED_TYPEDEF_FOR_SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point_
#define DEFINED_TYPEDEF_FOR_SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point_

struct SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point
{
  real_T X;
  real_T Y;
  real_T Z;
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

/* Parameters (default storage) */
typedef struct P_robotROSGetStartedExample_e_T_ P_robotROSGetStartedExample_e_T;

/* Forward declaration for rtModel */
typedef struct tag_RTM_robotROSGetStartedExa_T RT_MODEL_robotROSGetStartedEx_T;

#endif                  /* RTW_HEADER_robotROSGetStartedExample_edit_types_h_ */
