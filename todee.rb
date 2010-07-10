require 'todee_sockets'
require 'todee_codepoint'
require 'todee_codepoint_utils'
require 'todee_engine'

socket_manager = SocketManager.new()
socket_manager.register_socket(StdoutSocket.new(), 0)
socket_manager.register_socket(StackSocket.new(), 1)
socket_manager.register_socket(MemorySocket.new(), 2)
engine = Engine.new(socket_manager)

code = [[(MOV 1, '!'),   nil],
        [(MOV 1, 'o'),   nil],
        [(MOV 1, 'l'),   nil],
        [(MOV 1, 'l'),   nil],
        [(MOV 1, 'e'),   nil],
        [(MOV 1, 'h'),   nil],
        [(TUR 0),        (TNL 1)],
        [(MOV 2, 1.ref), (MOV 0, 2.ref)],
        [(TNL 2.ref),    (TNL 1)],
        [(STP()),        nil]]

#code = [[(TUR 0),         (MOV 0, '4'[0]), (TNL 1)],
#        [(MOV 0, '1'[0]),     nil,     (MOV 0, '3'[0])],
#        [(TNL 1),         (MOV 0, '2'[0]), (TNL 1)]]

engine.execute_all(code)
