Vim�UnDo� t�F��X�QM�D���}�4�V�FE�̙W  �   5        preview_amount = product.price_in_cents + 300  �   5      3       3   3   3    [��    _�                    �       ����                                                                                                                                                                                                                                                                                                                                                             [�]Z     �  �  �  �            �  �  �  �    5�_�                   �        ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�]b     �  �  �            end�  �  �              end�  �  �          2      expect(subject.total_in_cents).to eq(amount)�  �  �                amount = 1300�  �  �          +      # product plus non metered components�  �  �          B    it 'should not include metered component charges in amount' do�  �  �          ;    its(:subscription) { is_expected.to eql(subscription) }�  �  �          .    it { is_expected.to be_a BillingManifest }�  �  �              end�  �  �          ^      expect(subscription.component_for(quantity).update!(allocated_quantity: 3)).to be_truthy�  �  �          Z      expect(subscription.component_for(metered_2).update!(unit_balance: 10)).to be_truthy�  �  �          X      expect(subscription.component_for(metered).update!(unit_balance: 10)).to be_truthy�  �  �              before do�  �  �          �    let(:quantity)  { create(:quantity_based_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }�  �  �          i    let(:metered_2) { create(:metered_component, product_family: product.product_family, taxable: true) }�  �  �          �    let(:metered) { create(:metered_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }�  �  �          E    subject { described_class.billing_manifest(subscription.reload) }�  �  �          '        describe ".billing_manifest" do5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�]h     �  �  �  �      %      describe ".billing_manifest" do5�_�                   �        ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�]l     �  �  �  �      $      context ".billing_manifest" do5�_�                   �        ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�]y     �  �  �  �      	      end    �  �  �  �       5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�]}    �  �  �  �            context "" do5�_�                   �   F    ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�N�    �  �  �  �      I        subject { described_class.billing_manifest(subscription.reload) }5�_�      	             �   &    ����                                                                                                                                                                                                                                                                                                                           �          �           V        [�N�    �  �  �  �      
          �  �  �  �    5�_�      
           	  �        ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�UB     �  �  �  �      	      end    �  �  �  �           �  �  �  �      /      context "with a canceled subscription" do�  �  �          B        subject { described_class.billing_manifest(subscription) }   �        let(:metered) { create(:metered_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }   m        let(:metered_2) { create(:metered_component, product_family: product.product_family, taxable: true) }   �        let(:quantity)  { create(:quantity_based_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }           before do   \          expect(subscription.component_for(metered).update!(unit_balance: 10)).to be_truthy   ^          expect(subscription.component_for(metered_2).update!(unit_balance: 10)).to be_truthy   b          expect(subscription.component_for(quantity).update!(allocated_quantity: 3)).to be_truthy           end       2        it { is_expected.to be_a BillingManifest }   ?        its(:subscription) { is_expected.to eql(subscription) }       F        it 'should not include metered component charges in amount' do             binding.pry   /          # product plus non metered components             amount = 1300   6          expect(subject.total_in_cents).to eq(amount)           end   	      end5�_�   	              
  �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�UF     �  �  �  �    �  �  �  �    5�_�   
                �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�UG     �  �  �  �    5�_�                   �        ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�UJ    �  �  �  �      /      context "with a canceled subscription" do   B        subject { described_class.billing_manifest(subscription) }   �        let(:metered) { create(:metered_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }   m        let(:metered_2) { create(:metered_component, product_family: product.product_family, taxable: true) }   �        let(:quantity)  { create(:quantity_based_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }           before do   \          expect(subscription.component_for(metered).update!(unit_balance: 10)).to be_truthy   ^          expect(subscription.component_for(metered_2).update!(unit_balance: 10)).to be_truthy   b          expect(subscription.component_for(quantity).update!(allocated_quantity: 3)).to be_truthy           end       2        it { is_expected.to be_a BillingManifest }   ?        its(:subscription) { is_expected.to eql(subscription) }       F        it 'should not include metered component charges in amount' do             binding.pry   /          # product plus non metered components             amount = 1300   6          expect(subject.total_in_cents).to eq(amount)           end   	      end5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�W]    �  �  �  �              amount = 13005�_�                   �   .    ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�W�    �  �  �  �      .        amount = product.price_in_cents + 30005�_�                  �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[R     �  �  �  �            �  �  �  �    5�_�                   �   
    ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[X     �  �  �  �            let()5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[\     �  �  �  �            let(:preview)5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[]     �  �  �  �            let(:preview) {}5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[^     �  �  �  �            let(:preview) {  }5�_�                   �   *    ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�[f   	 �  �  �  �      -      let(:preview) { described_class.new() }5�_�                  �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�     �  �  �  �      -    context "with a canceled subscription" do5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�   
 �  �  �  �      :    context "reactivating with a canceled subscription" do5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�     �  �  �  �      @      subject { described_class.billing_manifest(subscription) }5�_�                   �   6    ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�    �  �  �  �      8      subject { preview.billing_manifest(subscription) }5�_�                   �   %    ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�    �  �  �  �      5    context "reactivating a canceled subscription" do5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[�    �  �  �                  binding.pry5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�\    �  �  �  �              �  �  �  �    5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�\<    �  �  �  �      ,    context "reactivating a subscription" do5�_�                    �       ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�\N    �  �  �                  pending5�_�      !              �       ����                                                                                                                                                                                                                                                                                                                                                             [��C     �  �  �          0      it { is_expected.to be_a BillingManifest }5�_�       "           !  �       ����                                                                                                                                                                                                                                                                                                                                                             [��D     �  �  �          =      its(:subscription) { is_expected.to eql(subscription) }5�_�   !   #           "  �        ����                                                                                                                                                                                                                                                                                                                                                             [��D     �  �  �           5�_�   "   $           #  �        ����                                                                                                                                                                                                                                                                                                                                                             [��G     �  �  �  �    5�_�   #   %           $  �        ����                                                                                                                                                                                                                                                                                                                           �         �          V       [��I     �  �  �  �      P      let(:preview) { described_class.new(subscription, is_reactivation: true) }    �  �  �  �      *      subject { preview.billing_manifest }5�_�   $   &           %  �        ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��L     �  �  �  �    �  �  �  �    5�_�   %   '           &  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��M    �  �  �  �    5�_�   &   (           '  �   Z    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��Q     �  �  �  �      Z        expect(subscription.component_for(metered).update!(unit_balance: 10)).to be_truthy5�_�   '   )           (  �   \    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��T     �  �  �  �      \        expect(subscription.component_for(metered_2).update!(unit_balance: 10)).to be_truthy5�_�   (   *           )  �   `    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��W     �  �  �  �      `        expect(subscription.component_for(quantity).update!(allocated_quantity: 3)).to be_truthy5�_�   )   +           *  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��[     �  �  �  �      R        expect(subscription.component_for(quantity).update!(allocated_quantity: 3)5�_�   *   ,           +  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��^     �  �  �  �      N        expect(subscription.component_for(metered_2).update!(unit_balance: 10)5�_�   +   -           ,  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��a    �  �  �  �      L        expect(subscription.component_for(metered).update!(unit_balance: 10)5�_�   ,   .           -  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��0    �  �  �          -        # product plus non metered components5�_�   -   /           .  �       ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [���     �  �  �  �      -        amount = product.price_in_cents + 3005�_�   .   0           /  �   -    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [���     �  �  �  �      4        expect(subject.total_in_cents).to eq(amount)5�_�   /   1           0  �   5    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [���     �  �  �  �      5        preview_amount = product.price_in_cents + 3005�_�   0   2           1  �   M    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [���     �  �  �  �      N        preview_amount = product.price_in_cents + subscription.component_for()5�_�   1   3           2  �   V    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [���     �  �  �  �      V        preview_amount = product.price_in_cents + subscription.component_for(quantity)5�_�   2               3  �   d    ����                                                                                                                                                                                                                                                                                                                           �   V      �   V       V       [��    �  �  �  �      d        preview_amount = product.price_in_cents + subscription.component_for(quantity).cost_in_cents5�_�                   �        ����                                                                                                                                                                                                                                                                                                                           �   ,      �          V   L    [�[}     �  �  �  �      /      context "with a canceled subscription" do   R        let(:preview) { described_class.new(subscription, is_reactivation: true) }   B        subject { described_class.billing_manifest(subscription) }   �        let(:metered) { create(:metered_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }   m        let(:metered_2) { create(:metered_component, product_family: product.product_family, taxable: true) }   �        let(:quantity)  { create(:quantity_based_component, multi_tier_component_attrs(price: 1.00, product_family: product.product_family)) }           before do   \          expect(subscription.component_for(metered).update!(unit_balance: 10)).to be_truthy   ^          expect(subscription.component_for(metered_2).update!(unit_balance: 10)).to be_truthy   b          expect(subscription.component_for(quantity).update!(allocated_quantity: 3)).to be_truthy           end       2        it { is_expected.to be_a BillingManifest }   ?        its(:subscription) { is_expected.to eql(subscription) }       F        it 'should not include metered component charges in amount' do             binding.pry   /          # product plus non metered components   /          amount = product.price_in_cents + 300   6          expect(subject.total_in_cents).to eq(amount)           end   	      end5�_�                   �       ����                                                                                                                                                                                                                                                                                                                           �         �          V       [�Y�    �  �  �        5��