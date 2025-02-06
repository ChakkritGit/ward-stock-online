part of 'order_bloc.dart';

sealed class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object> get props => [];
}

class OrderList extends OrderEvent {
  final List<Prescription>? orderList;

  const OrderList({this.orderList});

  @override
  List<Object> get props => [orderList ?? []];
}
