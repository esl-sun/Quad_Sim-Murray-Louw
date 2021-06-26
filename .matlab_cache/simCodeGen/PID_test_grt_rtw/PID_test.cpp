/*
 * PID_test.cpp
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

#include "PID_test.h"
#include "PID_test_private.h"

/* Model step function */
void PID_testModelClass::step()
{
  SL_Bus_PID_test_mavros_msgs_PositionTarget rtb_BusAssignment;

  /* Step: '<Root>/typemask' */
  if ((&PID_test_M)->Timing.t[0] < 0.0) {
    /* DataTypeConversion: '<Root>/Data Type Conversion' */
    PID_test_B.DataTypeConversion = 0U;
  } else {
    /* DataTypeConversion: '<Root>/Data Type Conversion' */
    PID_test_B.DataTypeConversion = 2111U;
  }

  /* End of Step: '<Root>/typemask' */

  /* Step: '<Root>/Step' */
  PID_test_B.Step[0] = 0.0;
  PID_test_B.Step[1] = 0.0;
  PID_test_B.Step[2] = 0.0;

  /* DataTypeConversion: '<Root>/Data Type Conversion1' incorporates:
   *  Constant: '<Root>/Constant'
   *  Sum: '<Root>/Sum'
   */
  PID_test_B.DataTypeConversion1 = 90.0F;

  /* BusAssignment: '<Root>/Bus Assignment' incorporates:
   *  Gain: '<S3>/Gain'
   */
  std::memset(&rtb_BusAssignment, 0, sizeof
              (SL_Bus_PID_test_mavros_msgs_PositionTarget));
  rtb_BusAssignment.TypeMask = PID_test_B.DataTypeConversion;
  rtb_BusAssignment.AccelerationOrForce.X = PID_test_B.Step[1];
  rtb_BusAssignment.AccelerationOrForce.Y = PID_test_B.Step[0];
  rtb_BusAssignment.AccelerationOrForce.Z = -PID_test_B.Step[2];
  rtb_BusAssignment.Yaw = PID_test_B.DataTypeConversion1;

  /* Outputs for Atomic SubSystem: '<Root>/Pub yaw_sp' */
  /* MATLABSystem: '<S2>/SinkBlock' */
  Pub_PID_test_297.publish(&rtb_BusAssignment);

  /* End of Outputs for SubSystem: '<Root>/Pub yaw_sp' */

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The absolute time is the multiplication of "clockTick0"
   * and "Timing.stepSize0". Size of "clockTick0" ensures timer will not
   * overflow during the application lifespan selected.
   */
  (&PID_test_M)->Timing.t[0] =
    ((time_T)(++(&PID_test_M)->Timing.clockTick0)) * (&PID_test_M)
    ->Timing.stepSize0;

  {
    /* Update absolute timer for sample time: [0.03s, 0.0s] */
    /* The "clockTick1" counts the number of times the code of this task has
     * been executed. The resolution of this integer timer is 0.03, which is the step size
     * of the task. Size of "clockTick1" ensures timer will not overflow during the
     * application lifespan selected.
     */
    (&PID_test_M)->Timing.clockTick1++;
  }
}

/* Model initialize function */
void PID_testModelClass::initialize()
{
  /* Registration code */
  {
    /* Setup solver object */
    rtsiSetSimTimeStepPtr(&(&PID_test_M)->solverInfo, &(&PID_test_M)
                          ->Timing.simTimeStep);
    rtsiSetTPtr(&(&PID_test_M)->solverInfo, &rtmGetTPtr((&PID_test_M)));
    rtsiSetStepSizePtr(&(&PID_test_M)->solverInfo, &(&PID_test_M)
                       ->Timing.stepSize0);
    rtsiSetErrorStatusPtr(&(&PID_test_M)->solverInfo, (&rtmGetErrorStatus
      ((&PID_test_M))));
    rtsiSetRTModelPtr(&(&PID_test_M)->solverInfo, (&PID_test_M));
  }

  rtsiSetSimTimeStep(&(&PID_test_M)->solverInfo, MAJOR_TIME_STEP);
  rtsiSetSolverName(&(&PID_test_M)->solverInfo,"FixedStepDiscrete");
  rtmSetTPtr((&PID_test_M), &(&PID_test_M)->Timing.tArray[0]);
  (&PID_test_M)->Timing.stepSize0 = 0.03;

  {
    int32_T i;
    char_T b_zeroDelimTopic[27];
    static const char_T tmp[26] = { '/', 'm', 'a', 'v', 'r', 'o', 's', '/', 's',
      'e', 't', 'p', 'o', 'i', 'n', 't', '_', 'r', 'a', 'w', '/', 'l', 'o', 'c',
      'a', 'l' };

    /* SystemInitialize for Atomic SubSystem: '<Root>/Pub yaw_sp' */
    /* Start for MATLABSystem: '<S2>/SinkBlock' */
    PID_test_DW.obj.matlabCodegenIsDeleted = false;
    PID_test_DW.objisempty = true;
    PID_test_DW.obj.isInitialized = 1;
    for (i = 0; i < 26; i++) {
      b_zeroDelimTopic[i] = tmp[i];
    }

    b_zeroDelimTopic[26] = '\x00';
    Pub_PID_test_297.createPublisher(&b_zeroDelimTopic[0], 1);
    PID_test_DW.obj.isSetupComplete = true;

    /* End of Start for MATLABSystem: '<S2>/SinkBlock' */
    /* End of SystemInitialize for SubSystem: '<Root>/Pub yaw_sp' */
  }
}

/* Model terminate function */
void PID_testModelClass::terminate()
{
  /* Terminate for Atomic SubSystem: '<Root>/Pub yaw_sp' */
  /* Terminate for MATLABSystem: '<S2>/SinkBlock' */
  if (!PID_test_DW.obj.matlabCodegenIsDeleted) {
    PID_test_DW.obj.matlabCodegenIsDeleted = true;
  }

  /* End of Terminate for MATLABSystem: '<S2>/SinkBlock' */
  /* End of Terminate for SubSystem: '<Root>/Pub yaw_sp' */
}

/* Constructor */
PID_testModelClass::PID_testModelClass() :
  PID_test_B(),
  PID_test_DW(),
  PID_test_M()
{
  /* Currently there is no constructor body generated.*/
}

/* Destructor */
PID_testModelClass::~PID_testModelClass()
{
  /* Currently there is no destructor body generated.*/
}

/* Real-Time Model get method */
RT_MODEL_PID_test_T * PID_testModelClass::getRTM()
{
  return (&PID_test_M);
}
