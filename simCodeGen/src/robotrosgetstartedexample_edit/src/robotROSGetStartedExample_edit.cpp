/*
 * robotROSGetStartedExample_edit.cpp
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

#include "robotROSGetStartedExample_edit.h"
#include "robotROSGetStartedExample_edit_private.h"

/* Model step function */
void robotROSGetStartedExample_editModelClass::step()
{
  SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point rtb_BusAssignment;
  real_T rtb_BusAssignment_tmp;

  /* BusAssignment: '<Root>/Bus Assignment' incorporates:
   *  Constant: '<S1>/Constant'
   */
  rtb_BusAssignment = robotROSGetStartedExample_edi_P.Constant_Value;

  /* Sin: '<Root>/Sine Wave' incorporates:
   *  Sin: '<Root>/Sine Wave1'
   */
  rtb_BusAssignment_tmp = (&robotROSGetStartedExample_ed_M)->Timing.t[0];

  /* BusAssignment: '<Root>/Bus Assignment' incorporates:
   *  Sin: '<Root>/Sine Wave'
   *  Sin: '<Root>/Sine Wave1'
   */
  rtb_BusAssignment.X = sin(robotROSGetStartedExample_edi_P.SineWave_Freq *
    rtb_BusAssignment_tmp + robotROSGetStartedExample_edi_P.SineWave_Phase) *
    robotROSGetStartedExample_edi_P.SineWave_Amp +
    robotROSGetStartedExample_edi_P.SineWave_Bias;
  rtb_BusAssignment.Y = sin(robotROSGetStartedExample_edi_P.SineWave1_Freq *
    rtb_BusAssignment_tmp + robotROSGetStartedExample_edi_P.SineWave1_Phase) *
    robotROSGetStartedExample_edi_P.SineWave1_Amp +
    robotROSGetStartedExample_edi_P.SineWave1_Bias;

  /* Outputs for Atomic SubSystem: '<Root>/Publish1' */
  /* MATLABSystem: '<S2>/SinkBlock' */
  Pub_robotROSGetStartedExample_edit_27.publish(&rtb_BusAssignment);

  /* End of Outputs for SubSystem: '<Root>/Publish1' */

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   */
  (&robotROSGetStartedExample_ed_M)->Timing.t[0] =
    ((time_T)(++(&robotROSGetStartedExample_ed_M)->Timing.clockTick0)) *
    (&robotROSGetStartedExample_ed_M)->Timing.stepSize0;

  {
    /* Update absolute timer for sample time: [0.01s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The resolution of this integer timer is 0.01, which is the step size
     * of the task. Size of "clockTick1" ensures timer will not overflow during the
     * application lifespan selected.
     */
    (&robotROSGetStartedExample_ed_M)->Timing.clockTick1++;
  }
}

/* Model initialize function */
void robotROSGetStartedExample_editModelClass::initialize()
{
  /* Registration code */
  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                          &(&robotROSGetStartedExample_ed_M)->Timing.simTimeStep);
    rtsiSetTPtr(&(&robotROSGetStartedExample_ed_M)->solverInfo, &rtmGetTPtr
                ((&robotROSGetStartedExample_ed_M)));
    rtsiSetStepSizePtr(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                       &(&robotROSGetStartedExample_ed_M)->Timing.stepSize0);
    rtsiSetErrorStatusPtr(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                          (&rtmGetErrorStatus((&robotROSGetStartedExample_ed_M))));
    rtsiSetRTModelPtr(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                      (&robotROSGetStartedExample_ed_M));
  }

  rtsiSetSimTimeStep(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                     MAJOR_TIME_STEP);
  rtsiSetSolverName(&(&robotROSGetStartedExample_ed_M)->solverInfo,
                    "FixedStepDiscrete");
  rtmSetTPtr((&robotROSGetStartedExample_ed_M),
             &(&robotROSGetStartedExample_ed_M)->Timing.tArray[0]);
  (&robotROSGetStartedExample_ed_M)->Timing.stepSize0 = 0.01;

  {
    int32_T i;
    char_T b_zeroDelimTopic[10];
    static const char_T tmp[9] = { '/', 'l', 'o', 'c', 'a', 't', 'i', 'o', 'n' };

    /* Start for Atomic SubSystem: '<Root>/Publish1' */
    /* Start for MATLABSystem: '<S2>/SinkBlock' */
    robotROSGetStartedExample_ed_DW.obj.matlabCodegenIsDeleted = false;
    robotROSGetStartedExample_ed_DW.objisempty = true;
    robotROSGetStartedExample_ed_DW.obj.isInitialized = 1;
    for (i = 0; i < 9; i++) {
      b_zeroDelimTopic[i] = tmp[i];
    }

    b_zeroDelimTopic[9] = '\x00';
    Pub_robotROSGetStartedExample_edit_27.createPublisher(&b_zeroDelimTopic[0],
      105);
    robotROSGetStartedExample_ed_DW.obj.isSetupComplete = true;

    /* End of Start for MATLABSystem: '<S2>/SinkBlock' */
    /* End of Start for SubSystem: '<Root>/Publish1' */
  }
}

/* Model terminate function */
void robotROSGetStartedExample_editModelClass::terminate()
{
  /* Terminate for Atomic SubSystem: '<Root>/Publish1' */
  /* Terminate for MATLABSystem: '<S2>/SinkBlock' */
  if (!robotROSGetStartedExample_ed_DW.obj.matlabCodegenIsDeleted) {
    robotROSGetStartedExample_ed_DW.obj.matlabCodegenIsDeleted = true;
  }

  /* End of Terminate for MATLABSystem: '<S2>/SinkBlock' */
  /* End of Terminate for SubSystem: '<Root>/Publish1' */
}

/* Constructor */
robotROSGetStartedExample_editModelClass::
  robotROSGetStartedExample_editModelClass() :
  robotROSGetStartedExample_ed_DW(),
  robotROSGetStartedExample_ed_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
robotROSGetStartedExample_editModelClass::
  ~robotROSGetStartedExample_editModelClass()
{
  /* Currently there is no destructor body generated.*/
}

/* Real-Time Model get method */
RT_MODEL_robotROSGetStartedEx_T * robotROSGetStartedExample_editModelClass::
  getRTM()
{
  return (&robotROSGetStartedExample_ed_M);
}
