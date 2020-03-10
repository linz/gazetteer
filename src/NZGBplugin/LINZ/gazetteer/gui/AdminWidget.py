################################################################################
#
#  New Zealand Geographic Board gazetteer application,
#  Crown copyright (c) 2020, Land Information New Zealand on behalf of
#  the New Zealand Government.
#
#  This file is released under the MIT licence. See the LICENCE file found
#  in the top-level directory of this distribution for more information.
#
################################################################################

import sys
import os.path

if __name__ == '__main__':
    from os.path import dirname, abspath
    lib = dirname(dirname(dirname(dirname(abspath(__file__)))))
    sys.path.append(lib)


from PyQt4.QtCore import *
from PyQt4.QtGui import *

from LINZ.Widgets import QtUtils
from LINZ.Widgets.SqlAlchemyAdaptor import SqlAlchemyAdaptor

# Import controller before model components to ensure database is configured..

from Controller import Controller
from LINZ.gazetteer.Model import User
from LINZ.gazetteer.Model import SystemCode
from Ui_AdminWidget import Ui_AdminWidget
import Config

class AdminWidget( QWidget, Ui_AdminWidget):

    def __init__( self, parent=None, userOnly=True):
        QWidget.__init__( self, parent)
        self.setupUi( self )
        self._controller = Controller.instance()
        self._database = self._controller.database()
        self._adaptor = SqlAlchemyAdaptor(User)
        self._currentUser = self._database.user()
        self._allUsers = {};
        self.uUpdatingLabel.hide()
        
        self.uPublishDatabase.clicked.connect( self.publishData )
        self.uDownloadCSV.hide()
        self.uDownloadCSV.clicked.connect( self.downloadCsvFiles )
        self.uUsersTable.rowSelectionChanged.connect( self.populateSelectedUser )
        self.uUserName.textChanged.connect( lambda x: self.setUserEditButtons() )
        self.uUserIsAdmin.clicked.connect( self.setUserEditButtons )
        self.uAddUser.clicked.connect( lambda x: self.updateUser('add') )
        self.uRemoveUser.clicked.connect( lambda x: self.updateUser('remove') )
        self.uUpdateUser.clicked.connect( lambda x: self.updateUser('update') )

        self.populateUsers()
        self.populateLastWebUpdate()


    def populateUsers( self ):
        users = list(self._database.query(User))
        allusers = {}
        for u in users:
            allusers[u.userid] = u
        self._allUsers = allusers
        self.uUsersTable.setList(users,
            adaptor=self._adaptor,
            columns=['userid','isdba'],
            headers=['Name','Admin?'])

    def populateSelectedUser( self ):
        user = self.uUsersTable.selectedItem()
        if user:
            self.uUserName.setText(user.userid)
            self.uUserIsAdmin.setChecked(user.isdba)
            self.setUserEditButtons()

    def populateLastWebUpdate( self ):
        label = ''
        update = SystemCode.lookup('SYSI','WEBU')
        if update:
            label = 'Last update: ' + update
        self.uLastUpdateLabel.setText( label )

    def setUserEditButtons( self ):
        userid = str(self.uUserName.text())
        isdba = self.uUserIsAdmin.isChecked()
        canUpdate = False
        canRemove = False
        canAdd = False
        if userid != self._currentUser:
            if userid in self._allUsers:
                canRemove = True
                if isdba != self._allUsers[userid].isdba:
                    canUpdate = True
            else:
                canAdd = True
        self.uAddUser.setEnabled(canAdd)
        self.uRemoveUser.setEnabled(canRemove)
        self.uUpdateUser.setEnabled(canUpdate)

    def updateUser( self, action ):
        userid = str(self.uUserName.text())
        isdba = self.uUserIsAdmin.isChecked()
        if action == 'add':
            result = QMessageBox.question(self, "Add new user",
                "Are you sure you want to add user " + userid + "\n\n" +
                "Please make sure that this is a valid network login id and is spelt correctly",
                QMessageBox.Yes | QMessageBox.No, QMessageBox.No )
            if result != QMessageBox.Yes:
                return
            u=User( userid=userid, isdba=isdba )
            self._database.add(u)
        elif action == 'remove':
            u = self._allUsers.get(userid)
            if u:
                self._database.delete(u)
        elif action == 'update':
            u=self._allUsers.get(userid)
            if u:
                u.isdba = isdba
                self._database.add(u)
        try:
            self._database.commit()
            self.populateUsers()
        except:
            msg = unicode(sys.exc_info()[1])
            QMessageBox.warning(self,"Error updating user",msg)

    def publishData( self ):
        result = QMessageBox.question( self, "Update web database",
                             'Are you sure you want to update the web database.\n'
                             'This will take it offline for several minutes, \n'
                             'and will publish all the information in it.',
                             QMessageBox.Yes | QMessageBox.No, QMessageBox.No )
        if result != QMessageBox.Yes:
            return
        oldCursor = self.cursor()
        try:
            self.uPublishDatabase.setEnabled(False)
            self.uUpdatingLabel.setText('Updating web database ...')
            self.uUpdatingLabel.show()
            self.setCursor( Qt.WaitCursor )
            # self.repaint()
            QApplication.processEvents() # QEventLoop.ExcludeUserInputEvents )
            self._database.execute('select gazetteer.gweb_update_web_database()')

            self.uUpdatingLabel.setText('Updating LDS and CSV data ...')
            self.repaint()
            self._database.execute('select gazetteer.gaz_update_export_database()')

            self.uUpdatingLabel.setText('Data published') #' (download CSV files now)')
        except:
            self.setCursor( oldCursor )
            msg = unicode(sys.exc_info()[1])
            QMessageBox.warning(self,"Error publishing data",msg)
            self.uPublishDatabase.setEnabled(True)
            self.uUpdatingLabel.hide()
        finally:
            self.setCursor( oldCursor )
        self.populateLastWebUpdate()

    def downloadCsvFiles( self ):
        from LINZ.gazetteer.Export import Export
        downloaddir = Config.get('CSVDownloadDirectory')
        dir= QFileDialog.getExistingDirectory( self, 'Select download folder',
                                              downloaddir )
        if not dir:
            return
        dir=unicode(dir)
        Config.set('CSVDownloadDirectory',dir)

        exp = Export()
        exports = []
        overwrite = []
        for table in exp.csvExportTables():
            csvfile = table
            if csvfile.lower().endswith('.csv'):
                csvfile = csvfile[:-4]
            csvfile = csvfile+'.csv'
            csvpath = os.path.join(dir,csvfile+'.csv')
            table = 'gazetteer_export.'+table
            if os.path.exists(csvpath):
                overwrite.append(csvfile)
            exports.append((table,csvfile))

        if not exports:
            QMessageBox.information(self,"No files","Currently no CSV download files are defined")
            return

        if overwrite:
            msg = ("The following files will be overwritten\n    "+
                   "\n    ".join(overwrite) +
                   "\nDo you want to continue?")
            result = QMessageBox.question(self,"Overwrite files?",msg,
                                          QMessageBox.Yes | QMessageBox.No )
            if result != QMessageBox.Yes:
                return

        oldCursor = self.cursor()
        try:
            self.setCursor( Qt.WaitCursor )
            # self.repaint()

            files = []
            for table, csvfile in exports:
                self.uUpdatingLabel.setText('Building '+csvfile)
                self.uUpdatingLabel.show()
                self.repaint()
                csvpath = os.path.join(dir,csvfile)
                exp.createCsvFile(table, csvpath)
                files.append(csvfile)
                msg = ("The following files will have been created \n    "+
                   "\n    ".join(files))
                QMessageBox.information(self,"CSV files written",msg)
        except:
            self.setCursor( oldCursor )
            msg = unicode(sys.exc_info()[1])
            QMessageBox.warning(self,"Error creating CSV file",msg)
        finally:
            self.setCursor( oldCursor )
            self.uUpdatingLabel.setText('')
            self.uUpdatingLabel.hide()

class AdminDialog( QDialog ):

    def __init__( self, parent=None ):
        QDialog.__init__( self, parent )
        layout = QVBoxLayout()
        layout.addWidget(AdminWidget())
        self.setLayout( layout )
        self.setWindowTitle("Gazetteer administration")

if __name__ == '__main__':
    app = QApplication([])
    dlg = AdminDialog()
    dlg.show()
    app.exec_()
    
    

