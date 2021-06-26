/*
 * robotROSGetStartedExample_edit.h
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

#ifndef RTW_HEADER_robotROSGetStartedExample_edit_h_
#define RTW_HEADER_robotROSGetStartedExample_edit_h_
#include <math.h>
#include <stddef.h>
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "slros_initialize.h"
#include "robotROSGetStartedExample_edit_types.h"

/* Shared type includes */
#include "multiword_types.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

#ifndef rtmGetT
#define rtmGetT(rtm)                   (rtmGetTPtr((rtm))[0])
#endif

#ifndef rtmGetTPtr
#define rtmGetTPtr(rtm)                ((rtm)->Timing.t)
#endif

#define robotROSGetStartedExample_edit_M (robotROSGetStartedExample_ed_M)

/* Block states (default storage) for system '<Root>' */
struct DW_robotROSGetStartedExample__T {
  ros_slroscpp_internal_block_P_T obj; /* '<S2>/SinkBlock' */
  boolean_T objisempty;                /* '<S2>/SinkBlock' */
};

/* Parameters (default storage) */
struct P_robotROSGetStartedExample_e_T_ {
  SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point Constant_Value;/* Computed Parameter: Constant_Value
                                                                      * Referenced by: '<S1>/Constant'
                                                                      */
  real_T SineWave_Amp;                 /* Expression: 1
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  real_T SineWave_Bias;                /* Expression: 0
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  real_T SineWave_Freq;                /* Expression: 2*pi/10
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  real_T SineWave_Phase;               /* Expression: -pi/2
                                        * Referenced by: '<Root>/Sine Wave'
                                        */
  real_T SineWave1_Amp;                /* Expression: 1
                                        * Referenced by: '<Root>/Sine Wave1'
                                        */
  real_T SineWave1_Bias;               /* Expression: 0
                                        * Referenced by: '<Root>/Sine Wave1'
                                        */
  real_T SineWave1_Freq;               /* Expression: 1
                                        * Referenced by: '<Root>/Sine Wave1'
                                        */
  real_T SineWave1_Phase;              /* Expression: 0
                                        * Referenced by: '<Root>/Sine Wave1'
                                        */
};

/* Real-time Model Data Structure */
struct tag_RTM_robotROSGetStartedExa_T {
  const char_T *errorStatus;
  RTWSolverInfo solverInfo;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    time_T stepSize0;
    uint32_T clockTick1;
    SimTimeStep simTimeStep;
    time_T *t;
    time_T tArray[2];
  } Timing;
};

/* Class declaration for model robotROSGetStartedExample_edit */
class robotROSGetStartedExample_editModelClass {
  /* public data and function members */
 public:
  /* model initialize function */
  void initialize();

  /* model step function */
  void step();

  /* model terminate function */
  void terminate();

  /* Constructor */
  robotROSGetStartedExample_editModelClass();

  /* Destructor */
  ~robotROSGetStartedExample_editModelClass();

  /* Real-Time Model get method */
  RT_MODEL_robotROSGetStartedEx_T * getRTM();

  /* private data and function members */
 private:
  /* Tunable parameters */
  static P_robotROSGetStartedExample_e_T robotROSGetStartedExample_edi_P;

  /* Block states */
  DW_robotROSGetStartedExample__T robotROSGetStartedExample_ed_DW;

  /* Real-Time Model */
  RT_MODEL_robotROSGetStartedEx_T robotROSGetStartedExample_ed_M;
};

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'robotROSGetStartedExample_edit'
 * '<S1>'   : 'robotROSGetStartedExample_edit/Blank Message'
 * '<S2>'   : 'robotROSGetStartedExample_edit/Publish1'
 */
#endif                        /* RTW_HEADER_robotROSGetStartedExample_edit_h_ */
