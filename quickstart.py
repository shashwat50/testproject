from __future__ import print_function
from googleapiclient.discovery import build
from httplib2 import Http
from oauth2client import file, client, tools
import sys

# If modifying these scopes, delete the file token.json.
SCOPES = 'https://www.googleapis.com/auth/spreadsheets'

# The ID and range of a sample spreadsheet.
SAMPLE_SPREADSHEET_ID = '1imKWvi-b5t4tIPQFpPpl1Bj4uzZ0DPrDv0BWkNPgtyI'
SAMPLE_RANGE_NAME = 'Sheet1!A:F'
valueInputOption='RAW'
values = [
	  [
		sys.argv[1],sys.argv[2],sys.argv[3],sys.argv[4]
	  ],
	 ]
body = {
            'values': values
        }

def main():
    """Shows basic usage of the Sheets API.
    Prints values from a sample spreadsheet.
    """
    # The file token.json stores the user's access and refresh tokens, and is
    # created automatically when the authorization flow completes for the first
    # time.
    store = file.Storage('token.json')
    creds = store.get()
    if not creds or creds.invalid:
        flow = client.flow_from_clientsecrets('credentials.json', SCOPES)
        creds = tools.run_flow(flow, store)
    service = build('sheets', 'v4', http=creds.authorize(Http()))

    # Call the Sheets API
    sheet = service.spreadsheets()
    result = sheet.values().append(spreadsheetId=SAMPLE_SPREADSHEET_ID,
                                range=SAMPLE_RANGE_NAME, valueInputOption=valueInputOption, body=body).execute()
#    pprint(result)

   # values = result.get('values', [])

    #if not values:
    #    print('No data found.')
    #else:
    #    print('Name, Major:')
    #    for row in values:
    #        # Print columns A and E, which correspond to indices 0 and 4.
    #        print('%s, %s' % (row[0], row[3]))

if __name__ == '__main__':
    main()
