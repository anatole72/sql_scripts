REM 
REM  Displays lock compatibility table.
REM  Includes detailed description of lock types.
REM 
REM  Author:  Mark Lang, 1998
REM

@_BEGIN
SET PAGESIZE 0
PROMPT +------------------------------------------------------------+
PROMPT |LOCKS DEFINED                                               |
PROMPT |                                                            |
PROMPT |RS  - Row Share           - no exclusive WRITE              |
PROMPT |RX  - Row eXclusive       - no exclusive READ or WRITE      |
PROMPT |S   - Share               - no modifications                |
PROMPT |SRX - Share Row eXclusive - no modifications or RX          |
PROMPT |X   - eXclusive           - no access period                |
PROMPT |                                                            |
PROMPT |TX  - Row Locks                                             |
PROMPT |TM  - Table Locks                                           |
PROMPT +--------------------------------+-------+---+---+---+---+---+ 
PROMPT |SQL Statement                   |Mode   |RS |RX |S  |SRX|X  |
PROMPT |                                |       |   |   |   |   |   |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT |SELECT ... FROM table ...       |none   |Y  |Y  |Y  |Y  |Y  |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT |INSERT INTO table ...           |none   |Y* |Y* |N  |N  |N  |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT |UPDATE table ...                |none   |Y* |Y* |N  |N  |N  |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT |DELETE FROM table ...           |none   |Y* |Y* |N  |N  |N  |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT |SELECT ... FROM table ...       |none   |Y* |Y* |Y* |Y* |N  |
PROMPT |  FOR UPDATE OF ...             |       |   |   |   |   |   |
PROMPT +--------------------------------+-------+---+---+---+---+---+
PROMPT
PROMPT * if no conflicting locks are held by another transaction.
PROMPT   Otherwise, waits occur.
@_END

