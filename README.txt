Assumptions and notes:

- In the CSV files new entries are separated with '\n' character. Separator character is ','. For different rules the parsing logic needs to be adjusted or an external library to be used. There is an example file "employees_log.csv" in the repository which I tested with.
- The task says to calculate periods when two employees worked together on a project. For that purpose, the algorithm calculates the overlap i.e. the period when both employees worked simultaneously on a given project.
- The output, as defined in task, will be one item with the Empoyee ID #1, Empoyee ID #2, Project ID, Days worked together. It is different from the sample output format given in the task document, which has only three items "143, 218, 8". Also, the algorithm will actually calculate the longest collaboration between employees on each project although the UI doesn't display it.
- App is compiled and tested under Xcode 15.3, iOS simulator iPhone 15 Pro (iOS 17.4)
- UI is very basic, if you want to see something specific, let me know and I can make a change. Obviously this aims to be just a demo implementation, not a finished product.
- The output of the whole algorithm might not be a single item in cases where we have different pairs or employees with equal days of working together on some project. Also if the same pair of employees worked together the exact same number of days ont two or more projects then all entries will show in the UI.
- There is a UISwitch to control if the app would try to recognize arbitary, date format or a set of predefined date formats(see EmployeesStatsPresenter.parseDate() method for implementation details)
- In terms of presentation architecture I used a simplified MVP pattern.
- Since the app doesn't use any third party libraries, no Podfile or packages have been added.