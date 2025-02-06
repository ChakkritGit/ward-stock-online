part of 'order_bloc.dart';

class OrderState extends Equatable {
  final List<Prescription> orderList;

  const OrderState({
    required this.orderList,
  });

  OrderState copywith({List<Prescription>? orderList}) {
    return OrderState(orderList: orderList ?? this.orderList);
  }

  @override
  List<Object> get props => [orderList];
}
