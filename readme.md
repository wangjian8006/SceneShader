<h1>һ�׳���shaderЧ��</h1>
<h2>AFT_Scene_Standard ������׼Shader</h2>
�㷨��LightMap + HalfLambert������ + BlinnPhong�߹�</br>
���Խ��ܣ�</br>
	����ɫ</br>
	����ͼ</br>
	������ͼ(û�з�����ͼ����������ģ��)</br>
	�߹���ͼ����ͨ������������ԵĻ�����ͨ���߹���뵽����ͼalpha������ʣ�������һ����ͼ��</br>
	HalfLambert  ����������</br>
	SpecularSharp �߹��������</br>
	SpecularIntensity �߹�ǿ��</br>

<h2>AFT_Scene_PBR ����PBRshader</h2>
�㷨��metallic workflow��PBR�������淴��</br>
���Խ��ܣ�</br>
	����ɫ</br>
	����ͼ</br>
	������ͼ(û�з�����ͼ����������ģ��)</br>
	�߹���ͼ��r��������ȣ�g����ֲڶȣ�</br>
	_Roughness (�����ֵС�ڵ���0��ʱ�򣬻�ʹ�ø߹���ͼ��g����ֲڶȣ�����ʹ�����ֵΪ�ֲڶ�)</br>
	_GlossMapScale ����ƽ����</br>

	_RefectionTex ������ͼ</br>
	_RefectionColor	������ɫ</br>
���ԣ�</br>
	�ڷ����л����£���Ҫ��һյƽ�й�������߹��뷨�ߡ�ʵ����Ϸ����Ҫ��</br>
	�ڵ�Ѩ�����£�Ϊshader�����˵��Դ�����ԣ�����������</br>

<h2>�ű�</h2>
	���ܵ�ʱ�����һ��SceneLightController����ŵ��������ϡ�</br>
	GlobalAmbientColor		��������</br>
	GlobalDirectionLightDir 	��������Դ��������������л�����ģ��ƽ�й⡿</br>
	GlobalDirectionLightColor	��������Դ��ɫ������������л�����ģ��ƽ�й⡿</br>
	bOpenPointLight			�Ƿ������Դ���߻����ã����ڵ�Ѩ�Ļ����»Ὺ�����Դ����������</br>
	GlobalPointLightRange		���Դ��Χ</br>
	GlobalPointLightColor		���Դ����ɫ</br>
	GlobalPointLightIntensity	���Դǿ��</br>
	GlobalPointLightSpecularSharp	���Դ�ĸ߹�</br>
	GlobalPointLightPositionYOffset	���Դ�ĸ߶�ƫ��ֵ</br>