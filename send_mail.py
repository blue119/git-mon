# http://codecomments.wordpress.com/2008/01/04/python-gmail-smtp-example/
import os
import sys
import smtplib
import mimetypes
from email.MIMEMultipart import MIMEMultipart
from email.MIMEBase import MIMEBase
from email.MIMEText import MIMEText
from email.MIMEAudio import MIMEAudio
from email.MIMEImage import MIMEImage
from email.Encoders import encode_base64

gmailUser = ''
gmailPassword = ''
recipient = ''


def sendMail(subject, text, attachmentFilePath):
    msg = MIMEMultipart()
    msg['From'] = gmailUser
    msg['To'] = recipient
    msg['Subject'] = subject
    msg.attach(MIMEText(open(attachmentFilePath,"rb").read(), 'html'))

    for file in [attachmentFilePath]:
        part = MIMEBase('application', "octet-stream")
        print file
        part.set_payload( open(file,"rb").read() )
        encode_base64(part)
        part.add_header('Content-Disposition', 'attachment; filename="%s"' % os.path.basename(file))
        msg.attach(part)

    mailServer = smtplib.SMTP('smtp.gmail.com', 587)
    mailServer.ehlo()
    mailServer.starttls()
    mailServer.ehlo()
    mailServer.login(gmailUser, gmailPassword)
    mailServer.sendmail(gmailUser, recipient, msg.as_string())
    mailServer.close()

    print('Sent email(%s) to %s' % (subject, recipient))

if __name__ == "__main__":

    sendMail(sys.argv[1], None, sys.argv[2])

