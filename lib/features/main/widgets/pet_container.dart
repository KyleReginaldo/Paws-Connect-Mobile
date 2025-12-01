// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:paws_connect/core/components/components.dart';
import 'package:paws_connect/core/router/app_route.gr.dart';
import 'package:paws_connect/features/pets/models/pet_model.dart';

import '../../../core/theme/paws_theme.dart';
import '../../../core/widgets/text.dart';

class PetContainer extends StatefulWidget {
  final Pet pet;
  final Function(int petId)? onFavoriteToggle;
  final bool isFavorite;
  const PetContainer({
    super.key,
    required this.pet,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  @override
  State<PetContainer> createState() => _PetContainerState();
}

class _PetContainerState extends State<PetContainer> {
  late bool isFav;

  @override
  void initState() {
    super.initState();
    isFav = widget.isFavorite;
  }

  @override
  void didUpdateWidget(PetContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync local state when isFavorite parameter changes from repository
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        isFav = widget.isFavorite;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InkWell(
          onTap: () {
            context.router.push(PetDetailRoute(id: widget.pet.id));
          },
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              border: Border(
                top: BorderSide(color: PawsColors.primary, width: 4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: NetworkImageView(
                        widget.pet.transformedPhotos.first,
                        width: MediaQuery.sizeOf(context).width * 0.40,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 4,
                      left: 4,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black26,
                        ),
                        child: PawsText(
                          DateFormat(
                            'MMM dd, yyyy',
                          ).format(widget.pet.createdAt),
                          fontSize: 12,
                          color: PawsColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    PawsText(
                      widget.pet.name != null && widget.pet.name!.isEmpty
                          ? 'Unnamed Pet'
                          : widget.pet.name!,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    if (widget.pet.adopted != null) ...[
                      SizedBox(width: 6),
                      PawsText(
                        'ADOPTED',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
                PawsText(widget.pet.age, fontSize: 14),
                PawsText(
                  widget.pet.breed,
                  fontSize: 14,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: PawsColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: IconButton.filled(
            style: ButtonStyle().copyWith(
              backgroundColor: WidgetStatePropertyAll(
                isFav
                    ? PawsColors.primary
                    : PawsColors.primary.withValues(alpha: 0.2),
              ),
            ),
            onPressed: widget.onFavoriteToggle != null
                ? () {
                    setState(() => isFav = !isFav);
                    widget.onFavoriteToggle!(widget.pet.id);
                  }
                : null,
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.white : PawsColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
