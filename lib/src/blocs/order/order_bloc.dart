// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:vending_standalone/src/models/order/order_model.dart';
part 'order_state.dart';
part 'order_event.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(const OrderState(orderList: [])) {
    on<OrderList>((event, emit) {
      emit(state.copywith(orderList: event.orderList));
    });
  }
}
