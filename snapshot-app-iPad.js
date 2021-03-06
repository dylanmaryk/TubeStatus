#import "SnapshotHelper.js"

var target = UIATarget.localTarget();
var app = target.frontMostApp();
var window = app.mainWindow();

window.tableViews()[0].cells()["Circle"].switches()[0].tap();
window.tableViews()[0].cells()["Hammersmith and City"].switches()[0].tap();
window.tableViews()[0].cells()["Piccadilly"].switches()[0].tap();
window.tableViews()[0].cells()["Victoria"].switches()[0].tap();
window.tableViews()[0].cells()["Overground"].switches()[0].tap();

captureLocalizedScreenshot("0-FirstScreen")

app.tabBar().buttons()["Notifications"].tap();

window.tableViews()[0].cells()["Monday"].switches()[0].tap();
window.tableViews()[0].cells()["Tuesday"].switches()[0].tap();
window.tableViews()[0].cells()["Wednesday"].switches()[0].tap();
window.tableViews()[0].cells()["Thursday"].switches()[0].tap();
window.tableViews()[0].cells()["Friday"].switches()[0].tap();

captureLocalizedScreenshot("1-SecondScreen")
