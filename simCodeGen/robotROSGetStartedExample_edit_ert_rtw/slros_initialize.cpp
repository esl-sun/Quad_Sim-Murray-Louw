#include "slros_initialize.h"

ros::NodeHandle * SLROSNodePtr;
const std::string SLROSNodeName = "robotROSGetStartedExample_edit";

// For Block robotROSGetStartedExample_edit/Publish1
SimulinkPublisher<geometry_msgs::Point, SL_Bus_robotROSGetStartedExample_edit_geometry_msgs_Point> Pub_robotROSGetStartedExample_edit_27;

void slros_node_init(int argc, char** argv)
{
  ros::init(argc, argv, SLROSNodeName);
  SLROSNodePtr = new ros::NodeHandle();
}

