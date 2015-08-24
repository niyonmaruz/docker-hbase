# https://happybase.readthedocs.org/en/latest/
# https://github.com/wbolster/happybase
import happybase

def main()
    HOST='hbase-docker'
    PORT=9090
    # Will create and then delete this table
    TABLE_NAME='table-name'
    
    connection = happybase.Connection(HOST, PORT)
    print("tables:%s", connection.tables())

    table = connection.table(TABLE_NAME)

    table.put('row-key', {'family:qual1': 'value1',
                          'family:qual2': 'value2'})

    row = table.row('row-key')
    print row['family:qual1']  # prints 'value1'

    for key, data in table.rows(['row-key-1', 'row-key-2']):
        print key, data  # prints row key and data for each row

    for key, data in table.scan(row_prefix='row'):
        print key, data  # prints 'value1' and 'value2'

    row = table.delete('row-key')

    connection.table_delete(TABLE_NAME, disable=True)

if __name__ == "__main__":
    main()
