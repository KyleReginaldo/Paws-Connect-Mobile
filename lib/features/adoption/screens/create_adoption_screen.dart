import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:paws_connect/core/supabase/client.dart';
import 'package:paws_connect/core/theme/paws_theme.dart';
import 'package:paws_connect/core/widgets/text.dart';
import 'package:paws_connect/core/widgets/text_field.dart';
import 'package:paws_connect/dependency.dart';
import 'package:paws_connect/features/adoption/provider/adoption_provider.dart';
import 'package:paws_connect/features/pets/repository/pet_repository.dart';
import 'package:paws_connect/features/profile/repository/profile_repository.dart';
import 'package:provider/provider.dart';

import '../../../core/dto/adoption.dto.dart';
import '../../../core/router/app_route.gr.dart';
import '../../../core/widgets/button.dart';

@RoutePage()
class CreateAdoptionScreen extends StatefulWidget implements AutoRouteWrapper {
  final int petId;
  const CreateAdoptionScreen({
    super.key,
    @PathParam('petId') required this.petId,
  });

  @override
  State<CreateAdoptionScreen> createState() => _CreateAdoptionScreenState();
  @override
  Widget wrappedRoute(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sl<ProfileRepository>()),
        ChangeNotifierProvider.value(value: sl<PetRepository>()),
      ],
      child: this,
    );
  }
}

class _CreateAdoptionScreenState extends State<CreateAdoptionScreen> {
  final _formKey = GlobalKey<FormState>();
  bool hasChildrenInHome = false;
  bool hasOtherPetsInHome = false;
  bool haveOutdoorSpace = false;
  bool havePermissionFromLandlord = false;
  bool isRenting = false;
  int numberOfHouseholdMembers = 2;
  String typeOfResidence = 'Apartment';
  final other = TextEditingController();

  void submitAdoptionRequest(AdoptionApplicationDTO dto, String petName) async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      EasyLoading.show(status: 'Submitting...');
      final result = await AdoptionProvider().submitAdoptionApplication(
        application: dto,
      );
      if (result.isError) {
        EasyLoading.dismiss();
        EasyLoading.showError(result.error);
      } else {
        EasyLoading.dismiss();
        EasyLoading.showSuccess(result.value);

        // Navigate to success screen
        context.router.replace(
          AdoptionSuccessRoute(
            petName: petName, // You can get the actual pet name from your data
            applicationId: result
                .value, // Assuming result.value contains the application ID
          ),
        );
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProfileRepository>().fetchUserProfile(USER_ID ?? "");
        context.read<PetRepository>().fetchPetById(widget.petId);
      }
    });
    super.initState();
  }

  Widget _buildRadioGroup({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PawsText(
          label,
          fontWeight: FontWeight.w500,
          color: PawsColors.textPrimary,
        ),
        AnimatedContainer(
          duration: Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: PawsColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () => onChanged(true),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: value ? Colors.white : PawsColors.border,
                  ),
                  child: PawsText(
                    'Yes',
                    color: value
                        ? PawsColors.primary
                        : PawsColors.textSecondary,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => onChanged(false),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: value ? PawsColors.border : Colors.white,
                  ),
                  child: PawsText(
                    'No',
                    color: value
                        ? PawsColors.textSecondary
                        : PawsColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = context.select((PetRepository repo) => repo.pet);
    final user = context.select((ProfileRepository repo) => repo.userProfile);

    return SafeArea(
      top: false,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          centerTitle: true,
          backgroundColor: PawsColors.primary,
          title: Text(
            'Create Adoption',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(
                    LucideIcons.info,
                    size: 16,
                    color: PawsColors.textSecondary,
                  ),
                  PawsText(
                    'Please make sure all information is accurate.',
                    color: PawsColors.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              PawsText(
                'Adoption Details',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: PawsColors.textPrimary,
              ),
              const SizedBox(height: 12),
              if (pet != null) ...[
                Row(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: pet.photos.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        PawsText(
                          pet.name,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                        PawsText('Breed: ${pet.breed}', fontSize: 14),
                        Row(
                          spacing: 10,
                          children: [
                            PawsText(
                              'Age: ${pet.age.toString()}',
                              fontSize: 14,
                            ),
                            PawsText('Weight: ${pet.weight}', fontSize: 14),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 10),
              ],
              if (user != null)
                PawsText(
                  'Applicant: ${user.username}',
                  fontWeight: FontWeight.w500,
                ),
              const SizedBox(height: 12),
              _buildRadioGroup(
                label: "Kid/s in the Household",
                value: hasChildrenInHome,
                onChanged: (val) => setState(() => hasChildrenInHome = val),
              ),
              SizedBox(height: 8),
              _buildRadioGroup(
                label: 'Other Pets in the Household',
                value: hasOtherPetsInHome,
                onChanged: (val) => setState(() => hasOtherPetsInHome = val),
              ),
              SizedBox(height: 8),

              _buildRadioGroup(
                label: 'Have Outdoor Space',
                value: haveOutdoorSpace,
                onChanged: (val) => setState(() => haveOutdoorSpace = val),
              ),
              SizedBox(height: 8),

              _buildRadioGroup(
                label: 'Permission from Landlord',
                value: havePermissionFromLandlord,
                onChanged: (val) =>
                    setState(() => havePermissionFromLandlord = val),
              ),
              SizedBox(height: 8),

              _buildRadioGroup(
                label: 'Renting',
                value: isRenting,
                onChanged: (val) => setState(() => isRenting = val),
              ),
              const SizedBox(height: 8),
              PawsText(
                'Number of Household Members',
                fontWeight: FontWeight.w500,
              ),
              TextFormField(
                initialValue: numberOfHouseholdMembers.toString(),
                decoration: InputDecoration(
                  hintText: 'Enter number',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (int.tryParse(val) == null) return 'Enter a number';
                  return null;
                },
                onSaved: (val) =>
                    numberOfHouseholdMembers = int.tryParse(val ?? '2') ?? 2,
              ),
              const SizedBox(height: 8),
              PawsText('Type of Residence', fontWeight: FontWeight.w500),
              DropdownButtonFormField<String>(
                value: typeOfResidence,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: ['Apartment', 'House', 'Condo', 'Other']
                    .map(
                      (type) =>
                          DropdownMenuItem(value: type, child: PawsText(type)),
                    )
                    .toList(),
                onChanged: (val) =>
                    setState(() => typeOfResidence = val ?? 'Apartment'),
                onSaved: (val) => typeOfResidence = val ?? 'Apartment',
              ),
              const SizedBox(height: 8),
              if (typeOfResidence == 'Other')
                PawsTextField(
                  hint: 'Specify other type of residence',
                  controller: other,
                  validator: (val) {
                    if (typeOfResidence == 'Other' &&
                        (val == null || val.isEmpty)) {
                      return 'Please specify';
                    }
                    return null;
                  },
                ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 10,
            children: [
              Row(
                spacing: 8,
                children: [
                  Icon(LucideIcons.info, size: 16),
                  Expanded(
                    child: PawsText(
                      'By submitting this form, you consent to the use of your information for processing your adoption request',
                      color: PawsColors.primary,
                    ),
                  ),
                ],
              ),
              PawsElevatedButton(
                label: 'Submit for Adoption',
                onPressed: () {
                  final dto = AdoptionApplicationDTO(
                    hasChildrenInHome: hasChildrenInHome,
                    hasOtherPetsInHome: hasOtherPetsInHome,
                    haveOutdoorSpace: haveOutdoorSpace,
                    havePermissionFromLandlord: havePermissionFromLandlord,
                    isRenting: isRenting,
                    numberOfHouseholdMembers: numberOfHouseholdMembers,
                    pet: widget.petId,
                    typeOfResidence: typeOfResidence == 'Other'
                        ? other.text.isNotEmpty
                              ? other.text
                              : 'Other'
                        : typeOfResidence,
                    user: USER_ID ?? '',
                  );
                  submitAdoptionRequest(dto, pet?.name ?? '');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
